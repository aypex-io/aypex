FactoryBot.define do
  factory :category_image, class: Aypex::CategoryImage do
    before(:create) do |category_image|
      if category_image.class.method_defined?(:attachment)
        category_image.attachment.attach(io: File.new(Aypex::Engine.root + "spec/fixtures/thinking-cat.jpg"), filename: "thinking-cat.jpg")
      end
    end
  end
end
