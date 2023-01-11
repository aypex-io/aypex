class AddMetadataToAypexTaxonsAndTaxonomies < ActiveRecord::Migration[5.2]
  def change
    %i[
      aypex_taxons
      aypex_taxonomies
    ].each do |table_name|
      change_table table_name do |t|
        if t.respond_to? :jsonb
          add_column table_name, :public_metadata, :jsonb
          add_column table_name, :private_metadata, :jsonb
        else
          add_column table_name, :public_metadata, :json
          add_column table_name, :private_metadata, :json
        end
      end
    end
  end
end
