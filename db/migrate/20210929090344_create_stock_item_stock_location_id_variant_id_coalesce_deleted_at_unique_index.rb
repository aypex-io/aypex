class CreateStockItemStockLocationIdVariantIdCoalesceDeletedAtUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :aypex_stock_items, name: :stock_item_by_loc_var_id_deleted_at
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE UNIQUE INDEX stock_item_by_loc_var_id_deleted_at
          ON aypex_stock_items(
            stock_location_id,
            variant_id,
            (COALESCE(deleted_at, CAST('1970-01-01' AS #{deleted_at_data_type})))
          );
        SQL
      end

      dir.down do
        remove_index :aypex_stock_items, name: :stock_item_by_loc_var_id_deleted_at
      end
    end
  end

  private

  def deleted_at_data_type
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      'DATETIME'
    when 'PostgreSQL'
      'TIMESTAMP'
    end
  end
end
