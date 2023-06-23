class CreateAypexStoreFavicons < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_store_favicons do |t|
      t.belongs_to :store
      t.timestamps
    end
  end
end
