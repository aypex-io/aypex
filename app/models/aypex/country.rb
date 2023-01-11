module Aypex
  class Country < Aypex::Base
    # we need to have this callback before any dependent: :destroy associations
    # https://github.com/rails/rails/issues/3458
    # before_destroy :ensure_not_default

    has_many :addresses, dependent: :restrict_with_error
    has_many :states,
      -> { order name: :asc },
      inverse_of: :country,
      dependent: :destroy
    has_many :zone_members,
      -> { where(zoneable_type: "Aypex::Country") },
      class_name: "Aypex::ZoneMember",
      dependent: :destroy,
      foreign_key: :zoneable_id
    has_many :zones, through: :zone_members, class_name: "Aypex::Zone"

    validates :name, :iso_name, :iso, :iso3, presence: true, uniqueness: {case_sensitive: false, scope: aypex_base_uniqueness_scope}

    def self.by_iso(iso)
      where(["LOWER(iso) = ?", iso.downcase]).or(where(["LOWER(iso3) = ?", iso.downcase])).take
    end

    def default?(store = nil)
      store ||= Aypex::Store.default
      self == store.default_country
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
