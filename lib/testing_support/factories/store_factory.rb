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

    trait :with_favicon do
      transient do
        filepath { Aypex::Engine.root.join("spec", "fixtures", "favicon.ico") }
        image_type { "image/x-icon" }
      end

      favicon_image do
        create(:favicon_image, favicon_attachment: Rack::Test::UploadedFile.new(filepath, image_type))
      end
    end
  end
end
