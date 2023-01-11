module Aypex
  module CalculatedAdjustments
    extend ActiveSupport::Concern

    included do
      has_one :calculator, class_name: "Aypex::Calculator", as: :calculable, inverse_of: :calculable, dependent: :destroy, autosave: true
      accepts_nested_attributes_for :calculator
      validates :calculator, presence: true
      delegate :compute, to: :calculator

      def self.calculators
        aypex_calculators.send model_name_without_aypex_namespace
      end

      def calculator_type
        calculator.class.to_s if calculator
      end

      def calculator_type=(calculator_type)
        klass = calculator_type.constantize if calculator_type
        self.calculator = klass.new if klass && !calculator.instance_of?(klass)
      end

      private

      def self.model_name_without_aypex_namespace
        to_s.tableize.tr("/", "_").sub("aypex_", "")
      end

      def self.aypex_calculators
        Rails.application.config.aypex.calculators
      end
    end
  end
end
