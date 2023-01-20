module Aypex
  module MultiStoreResource
    extend ActiveSupport::Concern

    included do
      scope :for_store, ->(store) { joins(:stores).where(Store.table_name => {id: store.id}) }

      validate :must_have_one_store, unless: :disable_store_presence_validation?
    end

    protected

    def must_have_one_store
      return if stores.any?

      errors.add(:stores, I18n.t(:must_have_one_store, scope: :aypex))
    end

    # this can be overridden on model basis
    def disable_store_presence_validation?
      Aypex::Config.disable_store_presence_validation
    end
  end
end
