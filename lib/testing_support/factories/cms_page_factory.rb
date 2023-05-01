FactoryBot.define do
  factory :base_cms_page, class: Aypex::CmsPage do
    title { generate(:random_string) }
    locale { "en" }

    store

    factory :cms_homepage do
      type { "Aypex::Cms::Page::Homepage" }
    end

    factory :cms_standard_page do
      type { "Aypex::Cms::Page::StandardPage" }
    end

    factory :cms_feature_page do
      type { "Aypex::Cms::Page::FeaturePage" }
    end
  end
end
