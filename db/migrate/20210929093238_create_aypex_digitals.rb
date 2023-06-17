class CreateAypexDigitals < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_digitals, if_not_exists: true do |t|
      t.belongs_to :variant

      t.timestamps
    end
  end
end
