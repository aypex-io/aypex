require "spec_helper"
require "cancan/matchers"
require "testing_support/ability_helpers"
require "testing_support/bar_ability"

# Fake ability for testing registration of additional abilities
class FooAbility
  include CanCan::Ability

  ORDER_NUMBER = "N210868"

  def initialize(_user)
    # allow anyone to perform index on Order
    can :index, Aypex::Order
    # allow anyone to update an Order with specific order number
    can :update, Aypex::Order do |order|
      order.number = ORDER_NUMBER
    end
  end
end

describe Aypex::Ability, type: :model do
  let(:store) { create(:store) }
  let(:user) { build(:user) }
  let(:ability) { Aypex::Ability.new(user) }
  let(:token) { nil }

  after do
    Aypex::Ability.abilities = Set.new
  end

  context "register_ability" do
    it "adds the ability to the list of abilities" do
      Aypex::Ability.register_ability(FooAbility)
      expect(Aypex::Ability.new(user).abilities).not_to be_empty
    end

    it "applies the registered abilities permissions" do
      Aypex::Ability.register_ability(FooAbility)
      expect(Aypex::Ability.new(user).can?(:update, create(:order, number: FooAbility::ORDER_NUMBER))).to be true
    end
  end

  describe "#abilities_to_register" do
    it "adds the ability to the list of abilities" do
      allow_any_instance_of(Aypex::Ability).to receive(:abilities_to_register).and_return([FooAbility])
      expect(Aypex::Ability.new(user).abilities).to include FooAbility
    end

    it "applies the registered abilities permissions" do
      allow_any_instance_of(Aypex::Ability).to receive(:abilities_to_register).and_return([FooAbility])
      expect(Aypex::Ability.new(user).can?(:update, create(:order, number: FooAbility::ORDER_NUMBER))).to be true
    end
  end

  context "for general resource" do
    let(:resource) { Object.new }

    context "with admin user" do
      before do
        allow(user).to receive(:persisted?).and_return(true)
        allow(user).to receive(:has_aypex_role?).and_return(true)
      end

      it_behaves_like "access granted"
      it_behaves_like "index allowed"
    end

    context "with customer" do
      it_behaves_like "access denied"
      it_behaves_like "no index allowed"
    end
  end

  context "for admin protected resources" do
    let(:resource) { Object.new }
    let(:resource_shipment) { Aypex::Shipment.new }
    let(:resource_product) { store.products.new }
    let(:resource_user) { create(:user) }
    let(:resource_order) { create(:order, user: resource_user) }
    let(:fakedispatch_user) { create(:user) }
    let(:fakedispatch_ability) { Aypex::Ability.new(fakedispatch_user) }

    context "with admin user" do
      context "admin user role" do
        it "is able to admin" do
          allow(user).to receive(:persisted?).and_return(true)
          allow(user).to receive(:aypex_admin?).and_return(true)
          expect(ability).to be_able_to :admin, resource
          expect(ability).to be_able_to :index, resource_order
          expect(ability).to be_able_to :show, resource_product
          expect(ability).to be_able_to :create, resource_user
        end
      end

      context "admin user class" do
        let(:user) { Aypex::DummyModel.create(name: "admin") }

        before { Aypex::Config.admin_user_class = "Aypex::DummyModel" }

        after { Aypex::Config.admin_user_class = nil }

        it "is able to admin" do
          allow(user).to receive(:persisted?).and_return(true)
          allow(user).to receive(:aypex_admin?).and_return(true)
          expect(ability).to be_able_to :admin, resource
          expect(ability).to be_able_to :index, resource_order
          expect(ability).to be_able_to :show, resource_product
          expect(ability).to be_able_to :create, resource_user
        end
      end
    end

    context "with fakedispatch user" do
      it "is able to admin on the order and shipment pages" do
        allow(user).to receive(:has_aypex_role?).with("admin").and_return(false)
        allow(user).to receive(:has_aypex_role?).with("bar").and_return(true)

        Aypex::Ability.register_ability(BarAbility)

        expect(ability).not_to be_able_to :admin, resource

        expect(ability).to be_able_to :admin, resource_order
        expect(ability).to be_able_to :index, resource_order
        expect(ability).not_to be_able_to :update, resource_order
        # ability.should_not be_able_to :create, resource_order # Fails

        expect(ability).to be_able_to :admin, resource_shipment
        expect(ability).to be_able_to :index, resource_shipment
        expect(ability).to be_able_to :create, resource_shipment

        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :update, resource_product
        # ability.should_not be_able_to :show, resource_product # Fails

        expect(ability).not_to be_able_to :admin, resource_user
        expect(ability).not_to be_able_to :update, resource_user
        expect(ability).to be_able_to :update, user
        # ability.should_not be_able_to :create, resource_user # Fails
        # It can create new users if is has access to the :admin, User!!
        expect(ability).to be_able_to :create, user

        # TODO: change the Ability class so only users and customers get the extra permissions?

        Aypex::Ability.remove_ability(BarAbility)
      end
    end

    context "with customer" do
      it "is not able to admin" do
        expect(ability).not_to be_able_to :admin, resource
        expect(ability).not_to be_able_to :admin, resource_order
        expect(ability).not_to be_able_to :admin, resource_product
        expect(ability).not_to be_able_to :admin, resource_user
      end
    end
  end

  context "as Guest User" do
    context "for Country" do
      let(:resource) { Aypex::Country.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for OptionType" do
      let(:resource) { Aypex::OptionType.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for OptionValue" do
      let(:resource) { Aypex::OptionType.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for Order" do
      let(:resource) { Aypex::Order.new }

      context "requested by same user" do
        before { resource.user = user }

        it_behaves_like "access granted"
        it_behaves_like "no index allowed"
      end

      context "requested by other user" do
        before { resource.user = Aypex::Config.user_class.new }

        it_behaves_like "create only"
      end

      context "requested with proper token" do
        let(:token) { "TOKEN123" }

        before { allow(resource).to receive_messages token: token }

        it_behaves_like "access granted"
        it_behaves_like "no index allowed"
      end

      context "requested with improper token" do
        let(:token) { "FAIL" }

        before { allow(resource).to receive_messages token: token }

        it_behaves_like "create only"
      end
    end

    context "for Product" do
      let(:resource) { store.products.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for ProductProperty" do
      let(:resource) { store.products.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for Property" do
      let(:resource) { store.products.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for State" do
      let(:resource) { Aypex::State.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for Categories" do
      let(:resource) { Aypex::Category.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for BaseCategory" do
      let(:resource) { Aypex::BaseCategory.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for User" do
      context "requested by same user" do
        let(:resource) { user }

        it_behaves_like "access granted"
        it_behaves_like "no index allowed"
      end

      context "requested by other user" do
        let(:resource) { create(:user) }

        it_behaves_like "create only"
      end
    end

    context "for Variant" do
      let(:resource) { Aypex::Variant.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end

    context "for Zone" do
      let(:resource) { Aypex::Zone.new }

      context "requested by any user" do
        it_behaves_like "read only"
      end
    end
  end
end
