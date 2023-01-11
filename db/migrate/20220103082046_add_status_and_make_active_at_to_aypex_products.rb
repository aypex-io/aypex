class AddStatusAndMakeActiveAtToAypexProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :aypex_products, :status, :string, null: false, default: 'draft'
    add_index :aypex_products, :status
    add_index :aypex_products, %i[status deleted_at]
  end
end
