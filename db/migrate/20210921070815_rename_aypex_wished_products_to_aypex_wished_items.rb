class RenameAypexWishedProductsToAypexWishedItems < ActiveRecord::Migration[5.2]
  def change
    rename_table :aypex_wished_products, :aypex_wished_items
  end
end
