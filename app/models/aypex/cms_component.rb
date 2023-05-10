module Aypex
  class CmsComponent < Aypex::Base
    include DisplayLink

    acts_as_list scope: :cms_section

    has_one :image, as: :viewable, dependent: :destroy, class_name: "Aypex::Image"
    accepts_nested_attributes_for :image, reject_if: :all_blank

    belongs_to :cms_section, class_name: "Aypex::CmsSection"

    validates :cms_section, :type, presence: true
    validate :reset_link_attributes
    validate :component_count, on: :create

    default_scope { order(position: :asc) }

    has_rich_text :content

    private

    def component_count
      return unless cms_section # Let Rails validates catch the presence of cms_section

      section_type = cms_section.type
      section_count = cms_section.cms_components.count
      max_number_of_components_allowed = cms_section.component_defaults[:count]

      return if max_number_of_components_allowed.nil?

      if section_count >= max_number_of_components_allowed
        errors.add(:cms_component, I18n.t("aypex.cms_section_only_allows", max_number_of_components_allowed: max_number_of_components_allowed, section_type: section_type))
      end
    end

    def reset_link_attributes
      if linked_resource_type_changed?
        return if linked_resource_id_was.nil?

        self.linked_resource_id = nil
      end
    end
  end
end
