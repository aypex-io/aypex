class AddSettingsToAypexCalculators < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_calculators do |t|
      if t.respond_to? :jsonb
        add_column :aypex_calculators, :settings, :jsonb
      else
        add_column :aypex_calculators, :settings, :json
      end
    end
  end
end
