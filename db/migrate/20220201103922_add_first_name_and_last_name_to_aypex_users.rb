class AddFirstNameAndLastNameToAypexUsers < ActiveRecord::Migration[5.2]
  def change
    if Aypex::Config.user_class.present?
      users_table_name = Aypex::Config.user_class.table_name
      add_column users_table_name, :first_name, :string unless column_exists?(users_table_name, :first_name)
      add_column users_table_name, :last_name, :string unless column_exists?(users_table_name, :last_name)
    end
  end
end
