class AddImageFilterToAypexOptionTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :aypex_option_types, :image_filterable, :boolean
  end
end
