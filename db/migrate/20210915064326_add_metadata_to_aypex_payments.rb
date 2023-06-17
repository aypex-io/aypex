class AddMetadataToAypexPayments < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_payments do |t|
      if t.respond_to? :jsonb
        add_column :aypex_payments, :public_metadata, :jsonb
        add_column :aypex_payments, :private_metadata, :jsonb
      else
        add_column :aypex_payments, :public_metadata, :json
        add_column :aypex_payments, :private_metadata, :json
      end
    end
  end
end
