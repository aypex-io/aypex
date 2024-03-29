class AddMetadataToAypexStockTransfers < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_stock_transfers do |t|
      if t.respond_to? :jsonb
        add_column :aypex_stock_transfers, :public_metadata, :jsonb
        add_column :aypex_stock_transfers, :private_metadata, :jsonb
      else
        add_column :aypex_stock_transfers, :public_metadata, :json
        add_column :aypex_stock_transfers, :private_metadata, :json
      end
    end
  end
end
