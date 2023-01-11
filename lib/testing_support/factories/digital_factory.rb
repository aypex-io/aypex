FactoryBot.define do
  factory :digital, class: Aypex::Digital do
    after(:build) do |digital|
      digital.attachment.attach(io: File.new("#{Aypex::Engine.root}/spec/fixtures/thinking-cat.jpg"),
        filename: "thinking-cat.jpg")
    end

    variant
  end
end
