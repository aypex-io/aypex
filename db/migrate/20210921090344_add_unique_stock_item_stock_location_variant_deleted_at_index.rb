class AddUniqueStockItemStockLocationVariantDeletedAtIndex < ActiveRecord::Migration[7.0]
  def change
    add_index :aypex_stock_items, [:stock_location_id, :variant_id, :deleted_at], name: 'stock_item_by_loc_var_id_deleted_at', unique: true
  end
end
