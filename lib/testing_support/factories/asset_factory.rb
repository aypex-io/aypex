FactoryBot.define do
  factory :asset, class: Aypex::Asset do
    viewable_type {}
    viewable_id {}
    position { 1 }
    alt {"Image Alt Text!"}
  end
end
