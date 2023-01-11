module Aypex
  class Promotion < Aypex::Base
    include MultiStoreResource
    include Metadata
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end
    if defined?(Aypex::Security::Promotions)
      include Aypex::Security::Promotions
    end

    MATCH_POLICIES = %w[all any]
    UNACTIVATABLE_ORDER_STATES = ["complete", "awaiting_return", "returned"]

    attr_reader :eligibility_errors, :generate_code

    belongs_to :promotion_category, optional: true

    has_many :promotion_rules, autosave: true, dependent: :destroy
    alias_method :rules, :promotion_rules

    has_many :promotion_actions, autosave: true, dependent: :destroy
    alias_method :actions, :promotion_actions

    has_many :order_promotions, class_name: "Aypex::OrderPromotion"
    has_many :orders, through: :order_promotions, class_name: "Aypex::Order"

    has_many :store_promotions, class_name: "Aypex::StorePromotion"
    has_many :stores, class_name: "Aypex::Store", through: :store_promotions

    accepts_nested_attributes_for :promotion_actions, :promotion_rules

    validates_associated :rules

    validates :name, presence: true
    validates :usage_limit, numericality: {greater_than: 0, allow_nil: true}
    validates :description, length: {maximum: 255}, allow_blank: true
    validate :expires_at_must_be_later_than_starts_at, if: -> { starts_at && expires_at }

    auto_strip_attributes :code, :path, :name

    scope :coupons, -> { where.not(code: nil) }
    scope :advertised, -> { where(advertise: true) }
    scope :applied, lambda {
      joins(<<-SQL).distinct
        INNER JOIN aypex_order_promotions
        ON aypex_order_promotions.promotion_id = #{table_name}.id
      SQL
    }

    self.whitelisted_ransackable_attributes = ["path", "promotion_category_id", "code"]

    def self.with_coupon_code(coupon_code)
      where("lower(#{table_name}.code) = ?", coupon_code.strip.downcase)
        .includes(:promotion_actions).where.not(aypex_promotion_actions: {id: nil})
        .last
    end

    def self.active
      where("aypex_promotions.starts_at IS NULL OR aypex_promotions.starts_at < ?", Time.current)
        .where("aypex_promotions.expires_at IS NULL OR aypex_promotions.expires_at > ?", Time.current)
    end

    def self.order_activatable?(order)
      order && !UNACTIVATABLE_ORDER_STATES.include?(order.state)
    end

    def generate_code=(generating_code)
      if ActiveModel::Type::Boolean.new.cast(generating_code)
        self.code = random_code
      end
    end

    def expired?
      !!(starts_at && Time.current < starts_at || expires_at && Time.current > expires_at)
    end

    def activate(payload)
      order = payload[:order]
      return unless self.class.order_activatable?(order)

      payload[:promotion] = self

      # Track results from actions to see if any action has been taken.
      # Actions should return nil/false if no action has been taken.
      # If an action returns true, then an action has been taken.
      results = actions.map do |action|
        action.perform(payload)
      end
      # If an action has been taken, report back to whatever activated this promotion.
      action_taken = results.include?(true)

      if action_taken
        # connect to the order
        # create the join_table entry.
        orders << order
        save
      end

      action_taken
    end

    # Called when a promotion is removed from the cart
    def deactivate(payload)
      order = payload[:order]
      return unless self.class.order_activatable?(order)

      payload[:promotion] = self

      # Track results from actions to see if any action has been taken.
      # Actions should return nil/false if no action has been taken.
      # If an action returns true, then an action has been taken.
      results = actions.map do |action|
        action.revert(payload) if action.respond_to?(:revert)
      end

      # If an action has been taken, report back to whatever `d this promotion.
      action_taken = results.include?(true)

      if action_taken
        # connect to the order
        # create the join_table entry.
        orders << order
        save
      end

      action_taken
    end

    # called anytime order.update_with_updater! happens
    def eligible?(promotable)
      return false if expired? || usage_limit_exceeded?(promotable) || blacklisted?(promotable)

      !!eligible_rules(promotable, {})
    end

    # eligible_rules returns an array of promotion rules where eligible? is true for the promotable
    # if there are no such rules, an empty array is returned
    # if the rules make this promotable ineligible, then nil is returned (i.e. this promotable is not eligible)
    def eligible_rules(promotable, options = {})
      # Promotions without rules are eligible by default.
      return [] if rules.none?

      specific_rules = rules.select { |rule| rule.applicable?(promotable) }
      return [] if specific_rules.none?

      rule_eligibility = specific_rules.map do |rule|
        [rule, rule.eligible?(promotable, options)]
      end.to_h

      if match_all?
        # If there are rules for this promotion, but no rules for this
        # particular promotable, then the promotion is ineligible by default.
        unless rule_eligibility.values.all?
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end
        specific_rules
      else
        unless rule_eligibility.values.any?
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end

        [rule_eligibility.detect { |_, eligibility| eligibility }.first]
      end
    end

    def products
      rules.where(type: "Aypex::Promotion::Rules::Product").map(&:products).flatten.uniq
    end

    def usage_limit_exceeded?(promotable)
      usage_limit.present? && usage_limit > 0 && adjusted_credits_count(promotable) >= usage_limit
    end

    def adjusted_credits_count(promotable)
      adjustments = promotable.is_a?(Order) ? promotable.all_adjustments : promotable.adjustments
      credits_count - adjustments.promotion.where(source_id: actions.pluck(:id)).size
    end

    def credits
      Adjustment.eligible.promotion.where(source_id: actions.map(&:id))
    end

    def credits_count
      credits.count
    end

    def line_item_actionable?(order, line_item)
      if eligible? order
        rules = eligible_rules(order)
        if rules.blank?
          true
        else
          rules.send(match_all? ? :all? : :any?) do |rule|
            rule.actionable? line_item
          end
        end
      else
        false
      end
    end

    def used_by?(user, excluded_orders = [])
      user.orders.complete.joins(:promotions).joins(:all_adjustments)
        .where.not(aypex_orders: {id: excluded_orders.map(&:id)})
        .where(aypex_promotions: {id: id})
        .where(aypex_adjustments: {source_type: "Aypex::PromotionAction", eligible: true}).any?
    end

    private

    def blacklisted?(promotable)
      case promotable
      when Aypex::LineItem
        !promotable.product.promotionable?
      when Aypex::Order
        promotable.line_items.any? &&
          promotable.line_items.joins(:product).where(aypex_products: {promotionable: true}).none?
      end
    end

    def match_all?
      match_policy == "all"
    end

    def expires_at_must_be_later_than_starts_at
      errors.add(:expires_at, :invalid_date_range) if expires_at < starts_at
    end

    def random_code
      loop do
        random_token = SecureRandom.hex(4)
        break random_token unless self.class.exists?(code: random_token)
      end
    end
  end
end
