module Aypex
  class CmsComponent < Aypex::Base
    include DisplayLink

    acts_as_list scope: :cms_section

    has_one :image, as: :viewable, dependent: :destroy, class_name: "Aypex::Image"
    accepts_nested_attributes_for :image

    belongs_to :cms_section, class_name: "Aypex::CmsSection"

    validate :reset_link_attributes
    validates :cms_section, :type, presence: true

    default_scope { order(position: :asc) }

    has_rich_text :body

    private

    def reset_link_attributes
      if linked_resource_type_changed?
        return if linked_resource_id_was.nil?

        self.linked_resource_id = nil
      end
    end
  end
end
