class OrderWalkthrough
  def self.up_to(state, store = nil)
    store ||= if Aypex::Store.exists?
      # Ensure the default store is used
      Aypex::Store.default || FactoryBot.create(:store, default: true)
    else
      # Create a default store
      FactoryBot.create(:store, default: true)
    end

    # A payment method must exist for an order to proceed through the Address state
    unless Aypex::PaymentMethod.exists?
      FactoryBot.create(:check_payment_method, stores: [store])
    end

    # Need to create a valid zone too...
    zone = FactoryBot.create(:zone)
    country = FactoryBot.create(:country)
    zone.members << Aypex::ZoneMember.create(zoneable: country)
    country.states << FactoryBot.create(:state, country:)

    # A shipping method must exist for rates to be displayed on checkout page
    unless Aypex::ShippingMethod.exists?
      FactoryBot.create(:shipping_method).tap do |sm|
        sm.calculator.amount = 10
        sm.calculator.currency = store.default_currency
        sm.calculator.save
      end
    end

    order = store.orders.create!(email: "aypex@example.com")
    add_line_item!(order)
    order.next!

    end_state_position = states.index(state.to_sym)
    states[0...end_state_position].each do |sta|
      send(sta, order)
    end

    order
  end

  def self.add_line_item!(order)
    FactoryBot.create(:line_item, order:)
    order.reload
  end

  def self.address(order)
    order.bill_address = FactoryBot.create(:address, country_id: Aypex::Zone.global.members.first.zoneable.id)
    order.ship_address = FactoryBot.create(:address, country_id: Aypex::Zone.global.members.first.zoneable.id)
    order.next!
  end

  def self.delivery(order)
    order.next!
  end

  def self.payment(order)
    FactoryBot.create :payment,
      order:,
      payment_method: Aypex::PaymentMethod.first,
      amount: order.total

    # TODO: maybe look at some way of making this payment_state change automatic
    order.payment_state = "paid"
    order.next!
  end

  def self.complete(_order)
    # noop?
  end

  def self.states
    [:address, :delivery, :payment, :complete]
  end
end
