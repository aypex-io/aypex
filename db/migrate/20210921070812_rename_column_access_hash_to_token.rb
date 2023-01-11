class RenameColumnAccessHashToToken < ActiveRecord::Migration[5.2]
  def change
    if table_exists?(:aypex_wishlists)
      rename_column(:aypex_wishlists, :access_hash, :token) if column_exists?(:aypex_wishlists, :access_hash)
      add_reference(:aypex_wishlists, :store, index: true) unless column_exists?(:aypex_wishlists, :store_id)
    end
  end
end
