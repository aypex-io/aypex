class AddBarcodeToAypexVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :aypex_variants, :barcode, :string
    add_index :aypex_variants, :barcode
  end
end
