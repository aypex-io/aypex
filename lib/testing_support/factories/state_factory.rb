FactoryBot.define do
  factory :state, class: Aypex::State do
    sequence(:name) { |n| "STATE_NAME_#{n}" }
    sequence(:abbr) { |n| "STATE_ABBR_#{n}" }
    country do |country|
      usa = Aypex::Country.find_by(numcode: 840)
      usa.present? ? usa : country.association(:country)
    end
  end
end
