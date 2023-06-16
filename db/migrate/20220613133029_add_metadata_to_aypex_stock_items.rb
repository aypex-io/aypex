class AddMetadataToAypexStockItems < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_stock_items do |t|
      if t.respond_to? :jsonb
        add_column :aypex_stock_items, :public_metadata, :jsonb
        add_column :aypex_stock_items, :private_metadata, :jsonb
      else
        add_column :aypex_stock_items, :public_metadata, :json
        add_column :aypex_stock_items, :private_metadata, :json
      end
    end
  end
end
