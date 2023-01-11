class AddMakeActiveAtToAypexProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :aypex_products, :make_active_at, :datetime
    add_index :aypex_products, :make_active_at

    Aypex::Product
      .where("discontinue_on IS NULL or discontinue_on > ?", Time.current)
      .where("available_on <= ?", Time.current)
      .where(status: "draft")
      .update_all(status: "active", updated_at: Time.current)

    Aypex::Product
      .where("discontinue_on <= ?", Time.current)
      .where.not(status: "archived")
      .update_all(status: "archived", updated_at: Time.current)
  end
end
