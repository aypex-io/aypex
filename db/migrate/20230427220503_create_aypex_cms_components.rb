class CreateAypexCmsComponents < ActiveRecord::Migration[7.0]
  def change
    create_table :aypex_cms_components do |t|
      t.string :type
      t.string :destination
      t.string :in_section_identifier
      t.integer :position
      t.references :linked_resource, polymorphic: true

      if t.respond_to? :jsonb
        t.jsonb :settings
      else
        t.json :settings
      end

      t.belongs_to :cms_section
      t.timestamps

      t.index [:position], name: "index_aypex_cms_components_on_position"
    end
  end
end
