module Aypex
  class Promotion
    module Rules
      # A rule to limit a promotion based on shipment country.
      class Country < PromotionRule
        typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
          s.integer :country_id
        end

        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, options = {})
          country = options[:country_id] || order.ship_address.try(:country_id)
          unless country.eql?(country_id || order.store.default_country_id)
            eligibility_errors.add(:base, eligibility_error_message(:wrong_country))
          end

          eligibility_errors.empty?
        end
      end
    end
  end
end
