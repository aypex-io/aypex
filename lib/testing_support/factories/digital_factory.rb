FactoryBot.define do
  factory :digital, class: Aypex::Digital do
    after(:build) do |digital|
      digital.attachment.attach(io: File.new("#{Aypex::Engine.root}/spec/fixtures/files/square.jpg"),
        filename: "square.jpg")
    end

    variant
  end
end
