class AddStoreIdToAypexAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_assets, :store_id, :bigint
    add_index :aypex_assets, [:store_id]
  end
end
