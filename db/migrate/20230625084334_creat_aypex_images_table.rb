class CreatAypexImagesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_images do |t|
      t.references :viewable, polymorphic: true
      t.belongs_to :asset

      t.timestamps
    end
  end
end
