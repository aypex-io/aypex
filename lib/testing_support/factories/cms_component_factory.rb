FactoryBot.define do
  factory :base_cms_component, class: Aypex::CmsComponent do
    association :cms_section, factory: :cms_section_image_hero

    factory :cms_component_image_hero do
      type { "Aypex::Cms::Component::ImageHero" }
    end

    factory :cms_component_featured_article do
      type { "Aypex::Cms::Component::FeaturedArticle" }
    end

    factory :cms_component_product_carousel do
      type { "Aypex::Cms::Component::ProductCarousel" }
    end

    factory :cms_component_image_mosaic do
      type { "Aypex::Cms::Component::ImageMosaic" }
    end

    factory :cms_component_image_pair do
      type { "Aypex::Cms::Component::ImagePair" }
    end

    factory :cms_component_rich_text do
      type { "Aypex::Cms::Component::RichText" }
    end
  end
end
