module Aypex
  class CmsSection < Aypex::Base
    acts_as_list scope: :cms_page
    belongs_to :cms_page, touch: true

    has_many :cms_components, class_name: "Aypex::CmsComponent", foreign_key: "cms_section_id"
    accepts_nested_attributes_for :cms_components

    default_scope { order(position: :asc) }

    validates :name, :cms_page, :type, presence: true

    after_create :ensure_components

    LINKED_RESOURCE_TYPES = []

    # cms_section_types_data
    #
    # Because cms_sections and cms_components are so closely related
    # we set basic data for the cms_sections and the corresponding cms_components
    # allowing us to build the default cms_components on create if needed.
    # if you do not require a component on creating your section, set count to 0
    #
    # Append new section types to this method.
    def cms_section_types_data
      [
        {
          name: "Hero Image",
          type: "Aypex::Cms::Section::HeroImage",
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Featured Article",
          type: "Aypex::Cms::Section::FeaturedArticle",
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Product Carousel",
          type: "Aypex::Cms::Section::ProductCarousel",
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Image Gallery",
          type: "Aypex::Cms::Section::ImageGallery",
          component_defaults: {
            count: 3,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Side By Side Images",
          type: "Aypex::Cms::Section::SideBySideImages",
          component_defaults: {
            count: 2,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Rich Text Content",
          type: "Aypex::Cms::Section::RichTextContent",
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        }
      ]
    end

    def boundaries
      ["Fit to Container", "Fit to Screen"]
    end

    def gutters_sizes
      ["With Gutters", "Without Gutters"]
    end

    def gutters?
      gutters == "With Gutters"
    end

    def full_screen?
      fit == "Fit to Screen"
    end

    # Builds the select array for each section
    def sections_for_select
      array = []

      cms_section_types_data.each do |data|
        array << [data[:name], data[:type]]
      end

      array
    end

    def ensure_components
      component_type = "Aypex::Cms::Component::#{type.demodulize}"
      section_data = cms_section_types_data.find { |section| section[:type] == type }

      raise StandardError unless section_data[:component_defaults][:count].is_a? Integer

      i = 0
      loop do
        break if section_data[:component_defaults][:count] <= 0

        i += 1

        CmsComponent.create!(
          cms_section_id: id,
          type: component_type,
          linked_resource_type: section_data[:component_defaults][:linked_resource_type]
        )

        break if i == section_data[:component_defaults][:count]
      end
    end
  end
end
