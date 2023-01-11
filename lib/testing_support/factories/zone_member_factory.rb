FactoryBot.define do
  factory :zone_member, class: Aypex::ZoneMember do
    zone { |member| member.association(:zone) }
    zoneable { |member| member.association(:zoneable) }
  end
end
