# Implementation class for CanCan gem. Instead of overriding this class, consider adding new permissions
# using the special +register_ability+ method which allows extensions to add their own abilities.
#
# See https://github.com/CanCanCommunity/cancancan for more details.
require "cancan"

module Aypex
  class Ability
    include CanCan::Ability

    class_attribute :abilities
    self.abilities = Set.new

    # Allows us to go beyond the standard cancan initialize method which makes it difficult for engines to
    # modify the default +Ability+ of an application.
    #
    # The +ability+ argument must be a class that includes the +CanCan::Ability+ module.
    # The registered ability should behave properly as a stand-alone class and therefore
    # should be easy to test in isolation.
    def self.register_ability(ability)
      abilities.add(ability)
    end

    def self.remove_ability(ability)
      abilities.delete(ability)
    end

    def initialize(user)
      alias_cancan_delete_action

      user ||= Aypex::Config.user_class.new

      if user.persisted? && user.try(:aypex_admin?)
        apply_admin_permissions(user)
      else
        apply_user_permissions(user)
      end

      protect_admin_role
    end

    protected

    # you can override this method to register your abilities
    # this method has to return array of classes
    def abilities_to_register
      []
    end

    def alias_cancan_delete_action
      alias_action :delete, to: :destroy
      alias_action :create, :update, :destroy, to: :modify
    end

    def apply_admin_permissions(user)
      can :manage, :all
    end

    def apply_user_permissions(user)
      can :read, ::Aypex::Country
      can :read, ::Aypex::Menu
      can :read, ::Aypex::CmsPage
      can :read, ::Aypex::OptionType
      can :read, ::Aypex::OptionValue
      can :create, ::Aypex::Order
      can :show, ::Aypex::Order do |order, token|
        order.user == user || order.token && token == order.token
      end
      can :update, ::Aypex::Order do |order, token|
        !order.completed? && (order.user == user || order.token && token == order.token)
      end
      can :manage, ::Aypex::Address, user_id: user.id
      can [:read, :destroy], ::Aypex::CreditCard, user_id: user.id
      can :read, ::Aypex::Product
      can :read, ::Aypex::ProductProperty
      can :read, ::Aypex::Property
      can :create, ::Aypex::Config.user_class
      can [:show, :update, :update_password], ::Aypex::Config.user_class, id: user.id
      can :read, ::Aypex::State
      can :read, ::Aypex::Store
      can :read, ::Aypex::Category
      can :read, ::Aypex::BaseCategory
      can :read, ::Aypex::Variant
      can :read, ::Aypex::Zone
      can :manage, ::Aypex::Wishlist, user_id: user.id
      can :show, ::Aypex::Wishlist do |wishlist|
        wishlist.user == user || wishlist.is_private == false
      end
      can [:create, :update, :destroy], ::Aypex::WishedItem do |wished_item|
        wished_item.wishlist.user == user
      end
    end

    def protect_admin_role
      cannot [:update, :destroy], ::Aypex::Role, name: ["admin"]
    end
  end
end
