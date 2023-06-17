class RenameAypexWishedProductsToAypexWishedItems < ActiveRecord::Migration[7.0]
  def change
    rename_table :aypex_wished_products, :aypex_wished_items
  end
end
