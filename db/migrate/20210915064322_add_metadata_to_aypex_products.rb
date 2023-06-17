class AddMetadataToAypexProducts < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_products do |t|
      if t.respond_to? :jsonb
        add_column :aypex_products, :public_metadata, :jsonb
        add_column :aypex_products, :private_metadata, :jsonb
      else
        add_column :aypex_products, :public_metadata, :json
        add_column :aypex_products, :private_metadata, :json
      end
    end
  end
end
