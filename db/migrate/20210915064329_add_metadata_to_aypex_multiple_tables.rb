class AddMetadataToAypexMultipleTables < ActiveRecord::Migration[7.0]
  def change
    %i[
      aypex_assets
      aypex_option_types
      aypex_option_values
      aypex_properties
      aypex_promotions
      aypex_payment_methods
      aypex_shipping_methods
      aypex_prototypes
      aypex_refunds
      aypex_customer_returns
      aypex_addresses
      aypex_credit_cards
      aypex_store_credits
    ].each do |table_name|
      change_table table_name do |t|
        if t.respond_to? :jsonb
          add_column table_name, :public_metadata, :jsonb
          add_column table_name, :private_metadata, :jsonb
        else
          add_column table_name, :public_metadata, :json
          add_column table_name, :private_metadata, :json
        end
      end
    end
  end
end
