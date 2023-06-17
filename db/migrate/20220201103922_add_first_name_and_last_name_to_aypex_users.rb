class AddFirstNameAndLastNameToAypexUsers < ActiveRecord::Migration[7.0]
  def change
    if Aypex::Config.user_class.present?
      add_column Aypex::Config.user_class.table_name, :first_name, :string, if_not_exists: true
      add_column Aypex::Config.user_class.table_name, :last_name, :string, if_not_exists: true
    end
  end
end
