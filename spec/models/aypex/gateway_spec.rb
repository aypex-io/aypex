require "spec_helper"

describe Aypex::Gateway do
  class Provider
    def initialize(options)
      # Keep
    end
  end

  class TestGateway < Aypex::Gateway
    typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
      s.string :publishable_preference1
      s.string :publishable_preference2
    end

    def options
      settings
    end

    def provider_class
      Provider
    end
  end

  it "passes through all arguments on a method_missing call" do
    gateway = TestGateway.new
    expect(gateway.provider).to receive(:imaginary_method).with("foo")
    gateway.imaginary_method("foo")
  end

  context "fetching payment sources" do
    let(:store) { create(:store) }
    let(:order) { store.orders.create(user_id: 1) }

    let(:has_card) { create(:credit_card_payment_method, stores: [store]) }
    let(:no_card) { create(:credit_card_payment_method, stores: [store]) }

    let(:cc) do
      create(:credit_card, payment_method: has_card, gateway_customer_profile_id: "EFWE")
    end

    let(:payment) do
      create(:payment, order: order, source: cc, payment_method: has_card)
    end

    it "finds credit cards associated on a order completed" do
      allow(payment.order).to receive_messages completed?: true

      expect(no_card.reusable_sources(payment.order)).to be_empty
      expect(has_card.reusable_sources(payment.order)).not_to be_empty
    end

    it "finds credit cards associated with the order user" do
      cc.update_column :user_id, 1
      allow(payment.order).to receive_messages completed?: false

      expect(no_card.reusable_sources(payment.order)).to be_empty
      expect(has_card.reusable_sources(payment.order)).not_to be_empty
    end
  end

  it "returns exchange multiplier for gateway" do
    gateway = TestGateway.new

    rate = Aypex::Gateway::FROM_DOLLAR_TO_CENT_RATE
    expect(gateway.exchange_multiplier).to eq rate
  end

  it "returns public settings" do
    gateway = TestGateway.new

    gateway.publishable_preference1 = "public 1"
    gateway.publishable_preference2 = "public 2"

    expect(gateway.publishable_preference1).to eq("public 1")
    expect(gateway.publishable_preference2).to eq("public 2")
  end
end
