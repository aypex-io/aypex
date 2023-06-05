FactoryBot.define do
  factory :base_cms_section, class: Aypex::CmsSection do
    association :cms_page, factory: :cms_feature_page

    factory :cms_section_image_hero do
      type { "Aypex::Cms::Section::ImageHero" }
    end

    factory :cms_section_featured_article do
      type { "Aypex::Cms::Section::FeaturedArticle" }
    end

    factory :cms_section_product_carousel do
      type { "Aypex::Cms::Section::ProductCarousel" }
    end

    factory :cms_section_image_mosaic do
      type { "Aypex::Cms::Section::ImageMosaic" }
    end

    factory :cms_section_image_pair do
      type { "Aypex::Cms::Section::ImagePair" }
    end

    factory :cms_section_rich_text do
      type { "Aypex::Cms::Section::RichText" }
    end
  end
end
