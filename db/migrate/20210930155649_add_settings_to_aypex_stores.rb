class AddSettingsToAypexStores < ActiveRecord::Migration[5.2]
  def change
    change_table :aypex_stores do |t|
      if t.respond_to? :jsonb
        add_column :aypex_stores, :settings, :jsonb
      else
        add_column :aypex_stores, :settings, :json
      end
    end
  end
end
