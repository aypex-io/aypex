module Aypex
  class Promotion
    module Rules
      class UserLoggedIn < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Aypex::Order)
        end

        def eligible?(order, _options = {})
          unless order.user.present?
            eligibility_errors.add(:base, eligibility_error_message(:no_user_specified))
          end
          eligibility_errors.empty?
        end
      end
    end
  end
end
