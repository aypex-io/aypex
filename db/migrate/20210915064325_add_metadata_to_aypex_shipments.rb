class AddMetadataToAypexShipments < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_shipments do |t|
      if t.respond_to? :jsonb
        add_column :aypex_shipments, :public_metadata, :jsonb
        add_column :aypex_shipments, :private_metadata, :jsonb
      else
        add_column :aypex_shipments, :public_metadata, :json
        add_column :aypex_shipments, :private_metadata, :json
      end
    end
  end
end
