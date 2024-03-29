class AddMetadataToAypexVariants < ActiveRecord::Migration[7.0]
  def change
    change_table :aypex_variants do |t|
      if t.respond_to? :jsonb
        add_column :aypex_variants, :public_metadata, :jsonb
        add_column :aypex_variants, :private_metadata, :jsonb
      else
        add_column :aypex_variants, :public_metadata, :json
        add_column :aypex_variants, :private_metadata, :json
      end
    end
  end
end
