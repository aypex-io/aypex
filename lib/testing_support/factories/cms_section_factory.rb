FactoryBot.define do
  factory :base_cms_section, class: Aypex::CmsSection do
    name { generate(:random_string) }

    association :cms_page, factory: :cms_feature_page

    factory :cms_hero_image_section do
      type { "Aypex::Cms::Sections::HeroImage" }
    end

    factory :cms_featured_article_section do
      type { "Aypex::Cms::Sections::FeaturedArticle" }
    end

    factory :cms_product_carousel_section do
      type { "Aypex::Cms::Sections::ProductCarousel" }
    end

    factory :cms_image_gallery_section do
      type { "Aypex::Cms::Sections::ImageGallery" }
    end

    factory :cms_side_by_side_images_section do
      type { "Aypex::Cms::Sections::SideBySideImages" }
    end

    factory :cms_rich_text_content_section do
      type { "Aypex::Cms::Sections::RichTextContent" }
    end
  end
end
