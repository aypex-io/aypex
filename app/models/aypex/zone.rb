module Aypex
  class Zone < Aypex::Base
    include UniqueName
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    with_options dependent: :destroy, inverse_of: :zone do
      has_many :zone_members, class_name: "Aypex::ZoneMember"
      has_many :tax_rates
    end
    with_options through: :zone_members, source: :zoneable do
      has_many :countries, source_type: "Aypex::Country"
      has_many :states, source_type: "Aypex::State"
    end

    has_many :shipping_method_zones, class_name: "Aypex::ShippingMethodZone"
    has_many :shipping_methods, through: :shipping_method_zones, class_name: "Aypex::ShippingMethod"

    scope :with_default_tax, -> { where(default_tax: true) }

    after_save :remove_defunct_members
    after_save :remove_previous_default, if: %i[default_tax? saved_change_to_default_tax?]

    alias_method :members, :zone_members
    accepts_nested_attributes_for :zone_members, allow_destroy: true, reject_if: proc { |a| a["zoneable_id"].blank? }

    self.whitelisted_ransackable_attributes = ["description"]

    def self.default_tax
      Rails.cache.fetch("default_tax") do
        find_by(default_tax: true)
      end
    end

    def self.potential_matching_zones(zone)
      if zone.country?
        # Match zones of the same kind with similar countries
        joins(countries: :zones)
          .where("zone_members_aypex_countries_join.zone_id = ?", zone.id)
          .distinct
      else
        # Match zones of the same kind with similar states in AND match zones
        # that have the states countries in
        joins(:zone_members).where(
          "(aypex_zone_members.zoneable_type = 'Aypex::State' AND
            aypex_zone_members.zoneable_id IN (?))
           OR (aypex_zone_members.zoneable_type = 'Aypex::Country' AND
            aypex_zone_members.zoneable_id IN (?))",
          zone.state_ids,
          zone.states.pluck(:country_id)
        ).distinct
      end
    end

    # Returns the matching zone with the highest priority zone type (State, Country, Zone.)
    # Returns nil in the case of no matches.
    def self.match(address)
      return unless address &&
        matches = includes(:zone_members)
          .order("aypex_zones.zone_members_count", "aypex_zones.created_at")
          .where("(aypex_zone_members.zoneable_type = 'Aypex::Country' AND " \
                          "aypex_zone_members.zoneable_id = ?) OR " \
                          "(aypex_zone_members.zoneable_type = 'Aypex::State' AND " \
                          "aypex_zone_members.zoneable_id = ?)", address.country_id, address.state_id)
          .references(:zones)

      %w[state country].each do |zone_kind|
        if match = matches.detect { |zone| zone_kind == zone.kind }
          return match
        end
      end
      matches.first
    end

    def self.default_checkout_zone
      ActiveSupport::Deprecation.warn("Aypex::Zone.default_checkout_zone is deprecated and will be removed in Aypex 5")

      first
    end

    def kind
      if self[:kind].present?
        self[:kind]
      else
        not_nil_scope = members.where.not(zoneable_type: nil)
        zone_type = not_nil_scope.order("created_at ASC").pluck(:zoneable_type).last
        zone_type&.demodulize&.underscore
      end
    end

    def country?
      kind == "country"
    end

    def state?
      kind == "state"
    end

    def include?(address)
      return false unless address

      members.any? do |zone_member|
        case zone_member.zoneable_type
        when "Aypex::Country"
          zone_member.zoneable_id == address.country_id
        when "Aypex::State"
          zone_member.zoneable_id == address.state_id
        end
      end
    end

    # convenience method for returning the countries contained within a zone
    def country_list
      @countries ||= case kind
      when "country"
        Country.where(id: country_ids)
      when "state"
        Country.where(id: zoneables.collect(&:country_id))
      end
    end

    def <=>(other)
      name <=> other.name
    end

    # All zoneables belonging to the zone members.  Will be a collection of either
    # countries or states depending on the zone type.
    def zoneables
      members.includes(:zoneable).collect(&:zoneable)
    end

    def country_ids
      if country?
        members.pluck(:zoneable_id)
      else
        []
      end
    end

    def state_ids
      if state?
        members.pluck(:zoneable_id)
      else
        []
      end
    end

    def country_ids=(ids)
      set_zone_members(ids, "Aypex::Country")
    end

    def state_ids=(ids)
      set_zone_members(ids, "Aypex::State")
    end

    # Indicates whether the specified zone falls entirely within the zone performing
    # the check.
    def contains?(target)
      return false if state? && target.country?
      return false if zone_members.empty? || target.zone_members.empty?

      if kind == target.kind
        if state?
          return false if (target.states.pluck(:id) - states.pluck(:id)).present?
        elsif country?
          return false if (target.countries.pluck(:id) - countries.pluck(:id)).present?
        end
      elsif (target.states.pluck(:country_id) - countries.pluck(:id)).present?
        return false
      end
      true
    end

    def state_list
      case kind
      when "country"
        zoneables.map(&:states)
      when "state"
        zoneables
      end.flatten.compact.uniq
    end

    def state_list_for(country)
      state_list.select { |state| state.country == country }
    end

    private

    def remove_defunct_members
      zone_members.defunct_without_kind(kind).destroy_all if zone_members.any?
    end

    def remove_previous_default
      Aypex::Zone.with_default_tax.where.not(id: id).update_all(default_tax: false)
      Rails.cache.delete("default_zone")
    end

    def set_zone_members(ids, type)
      zone_members.destroy_all
      ids.reject(&:blank?).map do |id|
        member = ZoneMember.new
        member.zoneable_type = type
        member.zoneable_id = id
        members << member
      end
    end
  end
end
