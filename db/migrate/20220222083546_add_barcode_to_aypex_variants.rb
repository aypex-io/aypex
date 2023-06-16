class AddBarcodeToAypexVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_variants, :barcode, :string
    add_index :aypex_variants, :barcode
  end
end
