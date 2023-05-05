FactoryBot.define do
  factory :base_cms_component, class: Aypex::CmsComponent do
    association :cms_section, factory: :cms_hero_section

    factory :cms_hero_component do
      type { "Aypex::Cms::Component::Hero" }
    end

    factory :cms_featured_article_component do
      type { "Aypex::Cms::Component::FeaturedArticle" }
    end

    factory :cms_product_carousel_component do
      type { "Aypex::Cms::Component::ProductCarousel" }
    end

    factory :cms_image_gallery_component do
      type { "Aypex::Cms::Component::ImageGallery" }
    end

    factory :cms_side_by_side_images_component do
      type { "Aypex::Cms::Component::SideBySideImages" }
    end

    factory :cms_rich_text_content_component do
      type { "Aypex::Cms::Component::RichTextContent" }
    end
  end
end
