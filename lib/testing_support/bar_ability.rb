# Fake ability for testing administration
class BarAbility
  include CanCan::Ability

  def initialize(user)
    user ||= Aypex::User.new
    if user.has_aypex_role? "bar"
      # allow dispatch to :admin, :index, and :show on Aypex::Order
      can [:admin, :index, :show], Aypex::Order
      # allow dispatch to :index, :show, :create and :update shipments on the admin
      can [:admin, :manage], Aypex::Shipment
    end
  end
end
