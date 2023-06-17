class AddInternalNoteToAypexOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_orders, :internal_note, :text
  end
end
