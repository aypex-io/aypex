class CreateAypexDigitals < ActiveRecord::Migration[5.2]
  def change
    create_table :aypex_digitals, if_not_exists: true do |t|
      t.belongs_to :variant

      t.timestamps
    end
  end
end
