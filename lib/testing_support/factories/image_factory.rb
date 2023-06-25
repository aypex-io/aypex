FactoryBot.define do
  factory :image, class: Aypex::Asset::Validate::Image do
    before(:create) do |image|
      if image.class.method_defined?(:attachment)
        image.attachment.attach(io: File.new(Aypex::Engine.root + "spec/fixtures/files" + "square.jpg"), filename: "square.jpg")
      end
    end
  end
end
