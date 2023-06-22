FactoryBot.define do
  factory :favicon_image, class: Aypex::StoreFaviconImage do
    transient do
      filepath { Aypex::Engine.root.join("spec", "fixtures", "favicon.ico") }
    end

    favicon_attachment { Rack::Test::UploadedFile.new(filepath) }
  end
end
