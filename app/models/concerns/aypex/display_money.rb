module Aypex
  module DisplayMoney
    ##
    # Takes a list of methods that the base object wants to be able to use
    # to display with Aypex::Money, and turns them into display_* methods.
    # Intended to help clean up some of the prepresentational logic that exists
    # at the model layer.
    #
    #
    # ==== Examples
    # Decorate a method, with the default option of using the base object's
    # currency
    #
    #     extend Aypex::DisplayMoney
    #     money_methods :tax_amount, :price
    #
    # Decorate a method, but with some additional options
    #     extend Aypex::DisplayMoney
    #     money_methods tax_amount: { currency: "CAD", no_cents: true }, :price
    # Use generated method with the same arguments as in wrapped method
    #     def tax_amount(order, country)
    #     display_tax_amount(order, country)
    def money_methods(*args)
      args.each do |money_method|
        money_method = {money_method => {}} unless money_method.is_a? Hash
        money_method.each do |method_name, opts|
          define_method("display_#{method_name}") do |**args_list|
            default_opts = respond_to?(:currency) ? {currency: currency} : {}

            amount = args_list.blank? ? send(method_name) : send(method_name, **args_list)

            Aypex::Money.new(amount, default_opts.merge(opts).merge(args_list.slice(:currency)))
          end
        end
      end
    end
  end
end
