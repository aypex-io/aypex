class CreateAypexDigitalLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_digital_links, if_not_exists: true do |t|
      t.belongs_to :digital
      t.belongs_to :line_item
      t.string :secret
      t.integer :access_counter

      t.timestamps
    end
    add_index :aypex_digital_links, :secret, unique: true unless index_exists?(:aypex_digital_links, :secret)
  end
end
