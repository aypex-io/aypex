class CreateAypexWishedProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :aypex_wished_products, if_not_exists: true do |t|
      t.references :variant
      t.belongs_to :wishlist

      t.column :quantity, :integer, default: 1, null: false

      t.timestamps
    end

    add_index :aypex_wished_products, [:variant_id, :wishlist_id], unique: true unless index_exists?(:aypex_wished_products, [:variant_id, :wishlist_id])
    add_index :aypex_wished_products, :variant_id unless index_exists?(:aypex_wished_products, :variant_id)
    add_index :aypex_wished_products, :wishlist_id unless index_exists?(:aypex_wished_products, :wishlist_id)
  end
end
