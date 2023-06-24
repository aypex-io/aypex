FactoryBot.define do
  factory :store, class: Aypex::Store do
    sequence(:code) { |i| "aypex_#{i}" }
    name { "Aypex Test Store" }
    url { "www.example.com" }
    mail_from_address { "no-reply@example.com" }
    customer_support_email { "support@example.com" }
    new_order_notifications_email { "store-owner@example.com" }
    default_currency { "USD" }
    supported_currencies { "USD,EUR,GBP" }
    default_locale { "en" }
    facebook { "aypex-commerce" }
    twitter { "aypex-commerce" }
    instagram { "aypex-commerce" }

    trait :logo do
      logo do
        create(:store_logo)
      end
    end

    trait :square_logo do
      square_logo do
        create(:store_square_logo)
      end
    end

    trait :icon do
      icon do
        create(:store_icon)
      end
    end
  end
end
