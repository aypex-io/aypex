module Aypex
  class CmsSection < Base
    include DisplayLink

    acts_as_list scope: :cms_page
    belongs_to :cms_page, touch: true

    validate :reset_link_attributes

    has_one :image_one, class_name: "Aypex::CmsSectionImageOne", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :image_one, reject_if: :all_blank

    has_one :image_two, class_name: "Aypex::CmsSectionImageTwo", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :image_two, reject_if: :all_blank

    has_one :image_three, class_name: "Aypex::CmsSectionImageThree", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :image_three, reject_if: :all_blank

    Aypex::CmsSectionImage::IMAGE_COUNT.each do |count|
      Aypex::CmsSectionImage::IMAGE_SIZE.each do |size|
        define_method("img_#{count}_#{size}") do |dimensions = nil|
          image = send("image_#{count}")&.attachment
          return if !image&.attached? || dimensions.nil?

          image.variant(resize_to_limit: dimensions.split("x").map(&:to_i))
        end
      end
    end

    default_scope { order(position: :asc) }

    validates :name, :cms_page, :type, presence: true

    LINKED_RESOURCE_TYPE = []

    TYPES = ["Aypex::Cms::Sections::HeroImage",
      "Aypex::Cms::Sections::FeaturedArticle",
      "Aypex::Cms::Sections::ProductCarousel",
      "Aypex::Cms::Sections::ImageGallery",
      "Aypex::Cms::Sections::SideBySideImages",
      "Aypex::Cms::Sections::RichTextContent"]

    def boundaries
      ["Container", "Screen"]
    end

    def css_classes
      ["row", "section-row"].compact
    end

    def gutters_sizes
      ["Gutters", "No Gutters"]
    end

    def fullscreen?
      fit == "Screen"
    end

    private

    def reset_link_attributes
      if linked_resource_type_changed?
        return if linked_resource_id_was.nil?

        self.linked_resource_id = nil
      end
    end
  end
end
