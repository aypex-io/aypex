class CreateAypexStoreMailerLogos < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_store_mailer_logos do |t|
      t.belongs_to :store
      t.timestamps
    end
  end
end
