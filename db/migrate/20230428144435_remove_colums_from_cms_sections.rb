class RemoveColumsFromCmsSections < ActiveRecord::Migration[7.0]
  def change
    remove_column :aypex_cms_sections, :name, :string
    remove_column :aypex_cms_sections, :content, :text
    remove_column :aypex_cms_sections, :settings, :text
    remove_column :aypex_cms_sections, :fit, :string
    remove_column :aypex_cms_sections, :destination, :string
    remove_column :aypex_cms_sections, :linked_resource_type, :string
    remove_column :aypex_cms_sections, :linked_resource_id, :bigint

    change_table :aypex_cms_sections do |t|
      if t.respond_to? :jsonb
        add_column :aypex_cms_sections, :settings, :jsonb
      else
        add_column :aypex_cms_sections, :settings, :json
      end
    end
  end
end
