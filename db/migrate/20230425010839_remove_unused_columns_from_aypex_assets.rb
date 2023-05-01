class RemoveUnusedColumnsFromAypexAssets < ActiveRecord::Migration[7.0]
  def change
    remove_column :aypex_assets, :type, :string
    remove_column :aypex_assets, :attachment_width, :integer
    remove_column :aypex_assets, :attachment_height, :integer
    remove_column :aypex_assets, :attachment_file_size, :integer
    remove_column :aypex_assets, :attachment_content_type, :string
    remove_column :aypex_assets, :attachment_file_name, :string
    remove_column :aypex_assets, :attachment_updated_at, :datetime
  end
end
