FactoryBot.define do
  factory :image, class: Aypex::Image do
    before(:create) do |image|
      if image.class.method_defined?(:attachment)
        image.attachment.attach(io: File.new(Aypex::Engine.root + "spec/fixtures" + "thinking-cat.jpg"), filename: "thinking-cat.jpg")
      end
    end
  end
end
