FactoryBot.define do
  factory :favicon_asset, class: Aypex::Asset::Image::Favicon do
    transient do
      filepath { Aypex::Engine.root.join("spec", "fixtures", "favicon.ico") }
      image_type { "image/x-icon" }
    end

    attachment { Rack::Test::UploadedFile.new(filepath, image_type) }
  end
end
