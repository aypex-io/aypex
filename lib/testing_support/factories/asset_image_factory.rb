FactoryBot.define do
  factory :asset_image, class: Aypex::Asset::Validate::Image do
    transient do
      filepath { Aypex::Engine.root.join("spec", "fixtures", "files", "img.gif") }
      image_type { "image/gif" }
    end

    attachment { Rack::Test::UploadedFile.new(filepath, image_type) }
  end
end
