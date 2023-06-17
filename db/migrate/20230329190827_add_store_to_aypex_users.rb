class AddStoreToAypexUsers < ActiveRecord::Migration[7.0]
  def change
    if Aypex::Config.user_class.present?
      users_table_name = Aypex::Config.user_class.table_name

      add_column users_table_name, :store_id, :bigint, null: false, if_not_exists: true
      add_index users_table_name, %i[email store_id], if_not_exists: true

      remove_index :aypex_users, :email, if_exists: true
    end
  end
end
