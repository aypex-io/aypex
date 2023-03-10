module Aypex
  class ZoneMember < Aypex::Base
    belongs_to :zone, class_name: "Aypex::Zone", counter_cache: true, inverse_of: :zone_members
    belongs_to :zoneable, polymorphic: true

    validates :zone, :zoneable, presence: true

    scope :defunct_without_kind, ->(kind) do
      where("zoneable_id IS NULL OR zoneable_type != ?", "Aypex::#{kind.classify}")
    end
  end
end
