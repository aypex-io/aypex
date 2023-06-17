class AddMetadataToAypexOrders < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_orders do |t|
      if t.respond_to? :jsonb
        add_column :aypex_orders, :public_metadata, :jsonb
        add_column :aypex_orders, :private_metadata, :jsonb
      else
        add_column :aypex_orders, :public_metadata, :json
        add_column :aypex_orders, :private_metadata, :json
      end
    end
  end
end
