FactoryBot.define do
  factory :menu_item, class: Aypex::MenuItem do
    sequence(:name) { |n| "Link no. #{n} To Somewhere" }
    item_type { "Link" }
    linked_resource_type { "Aypex::Linkable::Uri" }

    menu
    image
  end
end
