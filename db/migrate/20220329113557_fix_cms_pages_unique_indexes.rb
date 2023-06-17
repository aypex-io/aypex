class FixCmsPagesUniqueIndexes < ActiveRecord::Migration[7.0]
  def change
    remove_index :aypex_cms_pages, [:slug, :store_id, :deleted_at]
    remove_index :aypex_cms_pages, [:slug, :store_id], unique: true

    add_index :aypex_cms_pages, [:slug, :store_id, :deleted_at], unique: true
  end
end
