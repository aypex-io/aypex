FactoryBot.define do
  factory :asset_image_square_png, class: Aypex::Asset::Validate::ImageSquarePng do
    transient do
      filepath { Aypex::Engine.root.join("spec", "fixtures", "files", "square.png") }
      image_type { "image/png" }
    end

    attachment { Rack::Test::UploadedFile.new(filepath, image_type) }
  end
end
