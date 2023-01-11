class AddSettingsToAypexPromotionRules < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_promotion_rules do |t|
      if t.respond_to? :jsonb
        add_column :aypex_promotion_rules, :settings, :jsonb
      else
        add_column :aypex_promotion_rules, :settings, :json
      end
    end
  end
end
