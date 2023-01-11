class AddSettingsToAypexGateways < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_gateways do |t|
      if t.respond_to? :jsonb
        add_column :aypex_gateways, :settings, :jsonb
      else
        add_column :aypex_gateways, :settings, :json
      end
    end
  end
end
