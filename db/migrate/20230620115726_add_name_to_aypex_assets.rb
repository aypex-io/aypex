class AddNameToAypexAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_assets, :name, :string
  end
end
