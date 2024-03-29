module Aypex
  class CmsSection < Aypex::Base
    acts_as_list scope: :cms_page
    belongs_to :cms_page, touch: true

    has_many :cms_components, class_name: "Aypex::CmsComponent", foreign_key: "cms_section_id"
    accepts_nested_attributes_for :cms_components, reject_if: :all_blank

    default_scope { order(position: :asc) }

    validates :cms_page, :type, presence: true

    after_create :ensure_components

    LINKED_RESOURCE_TYPES = []

    # types_data
    #
    # Because cms_sections and cms_components are so closely related
    # we set basic data for the cms_sections and the corresponding cms_components
    # allowing us to build the default cms_components on create if needed.
    # if you do not require a component on creating your section, set count to 0
    #
    # Append new section types to this method.
    def types_data
      [
        {
          name: "Hero Image(s)",
          type: "Aypex::Cms::Section::ImageHero",
          description: I18n.t("aypex.cms_section.hero_description"),
          component_defaults: {
            count: nil,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Featured Article",
          type: "Aypex::Cms::Section::FeaturedArticle",
          description: I18n.t("aypex.cms_section.featured_article_description"),
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Product Carousel",
          type: "Aypex::Cms::Section::ProductCarousel",
          description: I18n.t("aypex.cms_section.product_carousel_description"),
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Image Gallery",
          type: "Aypex::Cms::Section::ImageMosaic",
          description: I18n.t("aypex.cms_section.mosaic_description"),
          component_defaults: {
            count: 3,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Side By Side",
          type: "Aypex::Cms::Section::ImagePair",
          description: I18n.t("aypex.cms_section.side_by_side_description"),
          component_defaults: {
            count: 2,
            linked_resource_type: "Aypex::Category"
          }
        },
        {
          name: "Rich Text Content",
          type: "Aypex::Cms::Section::RichText",
          description: I18n.t("aypex.cms_section.rich_text_description"),
          component_defaults: {
            count: 1,
            linked_resource_type: "Aypex::Category"
          }
        }
      ]
    end

    def component_defaults
      section_data = types_data.find { |section| section[:type] == type }
      section_data[:component_defaults]
    end

    def section_details
      types_data.find { |section| section[:type] == type }
    end

    private

    def ensure_components
      component_type = "Aypex::Cms::Component::#{type.demodulize}"
      number_of_components_allowed = component_defaults[:count]

      return if number_of_components_allowed.nil?

      raise StandardError unless number_of_components_allowed.is_a? Integer

      i = 0
      loop do
        break if number_of_components_allowed <= 0

        i += 1

        CmsComponent.create!(
          cms_section_id: id,
          type: component_type,
          linked_resource_type: component_defaults[:linked_resource_type]
        )

        break if i == number_of_components_allowed
      end
    end
  end
end
