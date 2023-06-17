class AddDeletedAtToAypexStores < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:aypex_stores, :deleted_at)
      add_column :aypex_stores, :deleted_at, :datetime
      add_index :aypex_stores, :deleted_at
    end
  end
end
