# TODO: let friendly id take care of sanitizing the url
require "stringex"

module Aypex
  class Category < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    extend FriendlyId
    friendly_id :permalink, slug_column: :permalink, use: :history
    before_validation :set_permalink, on: :create, if: :name

    acts_as_nested_set dependent: :destroy

    belongs_to :base_category, class_name: "Aypex::BaseCategory", inverse_of: :categories
    has_many :classifications, -> { order(:position) }, dependent: :delete_all, inverse_of: :category
    has_many :products, through: :classifications

    has_many :menu_items, as: :linked_resource
    has_many :cms_sections, as: :linked_resource

    has_many :prototype_categories, class_name: "Aypex::PrototypeCategory", dependent: :destroy
    has_many :prototypes, through: :prototype_categories, class_name: "Aypex::Prototype"

    has_many :promotion_rule_categories, class_name: "Aypex::PromotionRuleCategory", dependent: :destroy
    has_many :promotion_rules, through: :promotion_rule_categories, class_name: "Aypex::PromotionRule"

    validates :name, presence: true, uniqueness: {scope: [:parent_id, :base_category_id], allow_blank: true, case_sensitive: false}
    validates :base_category, presence: true
    validates :permalink, uniqueness: {case_sensitive: false, scope: [:parent_id, :base_category_id]}
    validates :hide_from_nav, inclusion: {in: [true, false]}

    validate :check_for_root, on: :create
    validate :parent_belongs_to_same_base_category
    with_options length: {maximum: 255}, allow_blank: true do
      validates :meta_keywords
      validates :meta_description
      validates :meta_title
    end

    before_validation :copy_base_category_from_parent
    after_save :touch_ancestors_and_base_category
    after_update :sync_base_category_name
    after_touch :touch_ancestors_and_base_category

    has_one :image, as: :viewable, dependent: :destroy, class_name: "Aypex::Asset::Validate::Image"
    accepts_nested_attributes_for :image, reject_if: :all_blank

    scope :for_store, ->(store) { joins(:base_category).where(aypex_base_categories: {store_id: store.id}) }

    self.whitelisted_ransackable_associations = %w[base_category]
    self.whitelisted_ransackable_attributes = %w[name permalink]

    scope :for_stores, ->(stores) { joins(:base_category).where(aypex_categories: {store_id: stores.ids}) }

    # indicate which filters should be used for a category
    # this method should be customized to your own site
    def applicable_filters
      filters = []
      # filters << ProductFilters.categories_below(self)
      ## unless it's a root category? left open for demo purposes

      filters << Aypex::ProductFilters.price_filter if Aypex::ProductFilters.respond_to?(:price_filter)
      filters << Aypex::ProductFilters.brand_filter if Aypex::ProductFilters.respond_to?(:brand_filter)
      filters
    end

    # Return meta_title if set otherwise generates from category name
    def seo_title
      meta_title.blank? ? name : meta_title
    end

    # Creates permalink base for friendly_id
    def set_permalink
      if parent.present?
        self.permalink = [parent.permalink, (permalink.blank? ? name.to_url : permalink.split("/").last)].join("/")
      elsif permalink.blank?
        self.permalink = name.to_url
      end
    end

    def active_products
      products.active
    end

    def pretty_name
      ancestor_chain = ancestors.inject("") do |name, ancestor|
        name + "#{ancestor.name} -> "
      end

      ancestor_chain + name.to_s
    end

    def cached_self_and_descendants_ids
      Rails.cache.fetch("#{cache_key_with_version}/descendant-ids") do
        self_and_descendants.ids
      end
    end

    # awesome_nested_set sorts by :lft and :rgt. This call re-inserts the child
    # node so that its resulting position matches the observable 0-indexed position.
    # ** Note ** no :position column needed - a_n_s doesn't handle the reordering if
    #  you bring your own :order_column.
    #
    #  See #3390 for background.
    def child_index=(idx)
      move_to_child_with_index(parent, idx.to_i) unless new_record?
    end

    private

    def sync_base_category_name
      if saved_change_to_name? && root?
        return if base_category.name.to_s == name.to_s

        base_category.update(name: name)
      end
    end

    def touch_ancestors_and_base_category
      # Touches all ancestors at once to avoid recursive base_category touch, and reduce queries.
      ancestors.update_all(updated_at: Time.current)
      # Have base_category touch happen in #touch_ancestors_and_base_category rather than association option in order for imports to override.
      base_category.try!(:touch)
    end

    def check_for_root
      if base_category.try(:root).present? && parent_id.nil?
        errors.add(:root_conflict, "this base_category already has a root category")
      end
    end

    def parent_belongs_to_same_base_category
      if parent.present? && parent.base_category_id != base_category_id
        errors.add(:parent, "must belong to the same base_category")
      end
    end

    def copy_base_category_from_parent
      self.base_category = parent.base_category if parent.present? && base_category.blank?
    end
  end
end
