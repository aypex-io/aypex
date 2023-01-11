class CreateAypexWishlists < ActiveRecord::Migration[5.2]
  def change
    create_table :aypex_wishlists, if_not_exists: true do |t|
      t.belongs_to :user
      t.belongs_to :store

      t.column :name, :string
      t.column :token, :string, null: false
      t.column :is_private, :boolean, default: true, null: false
      t.column :is_default, :boolean, default: false, null: false

      t.timestamps
    end

    add_index :aypex_wishlists, :token, unique: true
    add_index :aypex_wishlists, [:user_id, :is_default] unless index_exists?(:aypex_wishlists, [:user_id, :is_default])
  end
end
