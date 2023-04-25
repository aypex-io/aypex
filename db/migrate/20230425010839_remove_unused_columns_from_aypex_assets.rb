class RemoveUnusedColumnsFromAypexAssets < ActiveRecord::Migration[7.0]
  def change
    remove_column :aypex_assets, :type
    remove_column :aypex_assets, :attachment_width
    remove_column :aypex_assets, :attachment_height
    remove_column :aypex_assets, :attachment_file_size
    remove_column :aypex_assets, :attachment_content_type
    remove_column :aypex_assets, :attachment_file_name
    remove_column :aypex_assets, :attachment_updated_at
  end
end
