FactoryBot.define do
  factory :zone, class: Aypex::Zone do
    name { generate(:random_string) }
    description { generate(:random_string) }

    factory :zone_with_country do
      kind { :country }

      zone_members do |proxy|
        zone = proxy.instance_eval { @instance }

        [Aypex::ZoneMember.create(zoneable: create(:country), zone: zone)]
      end

      factory :global_zone, class: Aypex::Zone do
        sequence(:name) { |n| "GlobalZone_#{n}" }

        zone_members do |proxy|
          zone = proxy.instance_eval { @instance }

          Aypex::Country.all.map do |country|
            Aypex::ZoneMember.where(zoneable: country, zone:).first_or_create
          end
        end
      end
    end
  end
end
