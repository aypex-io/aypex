module Aypex
  class Calculator < Aypex::Base
    acts_as_paranoid

    belongs_to :calculable, polymorphic: true, optional: true, inverse_of: :calculator

    # This method calls a compute_<computable> method. must be overridden in concrete calculator.
    #
    # It should return amount computed based on #calculable and the computable parameter
    def compute(computable)
      # Aypex::LineItem -> :compute_line_item
      computable_name = computable.class.name.demodulize.underscore
      method = "compute_#{computable_name}".to_sym
      calculator_class = self.class
      if respond_to?(method)
        send(method, computable)
      else
        raise NotImplementedError, "Please implement '#{method}(#{computable_name})' in your calculator: #{calculator_class.name}"
      end
    end

    # overwrite to provide description for your calculators
    def self.description
      "Base Calculator"
    end

    # Returns all calculators applicable for kind of work
    def self.calculators
      Rails.application.config.aypex.calculators
    end

    def to_s
      self.class.name.titleize.gsub("Calculator/", "")
    end

    def description
      self.class.description
    end

    def available?(_object)
      true
    end
  end
end
