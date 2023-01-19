module Aypex
  class ReturnItem::EligibilityValidator::BaseValidator
    attr_reader :errors

    def initialize(return_item)
      @return_item = return_item
      @errors = {}
    end

    def eligible_for_return?
      raise NotImplementedError, I18n.t(:implement_eligible_for_return, scope: :aypex)
    end

    def requires_manual_intervention?
      raise NotImplementedError, I18n.t(:implement_requires_manual_intervention, scope: :aypex)
    end

    private

    def add_error(key, error)
      @errors[key] = error
    end
  end
end
