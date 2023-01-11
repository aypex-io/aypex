class AddInternalNoteToAypexOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :aypex_orders, :internal_note, :text
  end
end
