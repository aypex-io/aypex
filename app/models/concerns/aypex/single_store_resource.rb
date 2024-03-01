module Aypex
  module SingleStoreResource
    extend ActiveSupport::Concern

    included do
      validate :ensure_store_association_is_not_changed
      validates :store_id, presence: true

      scope :for_store, ->(store) { where(store_id: store.id) }
    end

    protected

    def ensure_store_association_is_not_changed
      if store_id_changed? && persisted?
        errors.add(:store, I18n.t("aypex.errors.messages.store_association_can_not_be_changed"))
      end
    end
  end
end
