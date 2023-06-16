class AddSelectedLocaleToAypexUsers < ActiveRecord::Migration[7.0]
  def change
    if Aypex::Config.user_class.present?
      add_column Aypex::Config.user_class.table_name, :selected_locale, :string, if_not_exists: true
    end
  end
end
