class AddMetadataToAypexTaxRates < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_tax_rates do |t|
      if t.respond_to? :jsonb
        add_column :aypex_tax_rates, :public_metadata, :jsonb
        add_column :aypex_tax_rates, :private_metadata, :jsonb
      else
        add_column :aypex_tax_rates, :public_metadata, :json
        add_column :aypex_tax_rates, :private_metadata, :json
      end
    end
  end
end
