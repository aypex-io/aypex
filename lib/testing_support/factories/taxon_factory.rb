FactoryBot.define do
  factory :taxon, class: Aypex::Taxon do
    sequence(:name) { |n| "taxon_#{n}" }

    association :taxonomy, strategy: :create
    association :icon, factory: :taxon_image
    parent_id { taxonomy.root.id }
  end
end
