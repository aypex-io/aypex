class AddMetadataToAypexCategoriesAndBaseCategories < ActiveRecord::Migration[7.0]
  def change
    %i[
      aypex_categories
      aypex_base_categories
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
