FactoryBot.define do
  factory :asset_image_square, class: Aypex::Asset::Validate::ImageSquare do
    transient do
      filepath { Aypex::Engine.root.join("spec", "fixtures", "files", "square.gif") }
      image_type { "image/gif" }
    end

    attachment { Rack::Test::UploadedFile.new(filepath, image_type) }
  end
end
