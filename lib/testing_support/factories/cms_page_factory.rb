FactoryBot.define do
  factory :base_cms_page, class: Aypex::CmsPage do
    title { generate(:random_string) }
    locale { "en" }

    store

    factory :cms_homepage do
      type { "Aypex::Cms::Pages::Homepage" }
    end

    factory :cms_standard_page do
      type { "Aypex::Cms::Pages::StandardPage" }
    end

    factory :cms_feature_page do
      type { "Aypex::Cms::Pages::FeaturePage" }
    end
  end
end
