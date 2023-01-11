class AddSelectedLocaleToAypexUsers < ActiveRecord::Migration[6.1]
  def change
    if Aypex::Config.user_class.present?
      users_table_name = Aypex::Config.user_class.table_name
      add_column users_table_name, :selected_locale, :string unless column_exists?(users_table_name, :selected_locale)
    end
  end
end
