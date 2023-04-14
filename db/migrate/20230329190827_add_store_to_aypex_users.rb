class AddStoreToAypexUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_users, :store_id, :bigint
    add_index :aypex_users, %i[email store_id], if_not_exists: true

    remove_index :aypex_users, :email if index_exists?(:aypex_users, :email)
  end
end
