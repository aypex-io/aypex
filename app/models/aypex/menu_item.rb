module Aypex
  class MenuItem < Aypex::Base
    include Aypex::DisplayLink
    if defined?(Aypex::Webhooks)
      include Aypex::Webhooks::HasWebhooks
    end

    acts_as_nested_set dependent: :destroy

    ITEM_TYPE = %w[Link Container]
    LINKED_RESOURCE_TYPE = ["Aypex::Linkable::Uri", "Aypex::Linkable::Homepage", "Aypex::Product", "Aypex::Taxon", "Aypex::CmsPage"]

    belongs_to :menu, touch: true

    before_create :ensure_item_belongs_to_root
    before_update :reset_link_attributes
    before_save :paremeterize_code

    after_save :touch_ancestors_and_menu
    after_touch :touch_ancestors_and_menu

    validates :name, :menu, presence: true
    validates :item_type, inclusion: {in: ITEM_TYPE}
    validates :linked_resource_type, inclusion: {in: LINKED_RESOURCE_TYPE}

    has_one :icon, as: :viewable, dependent: :destroy, class_name: "Aypex::Icon"
    accepts_nested_attributes_for :icon, reject_if: :all_blank

    def container?
      item_type == "Container"
    end

    def code?(item_code = nil)
      if item_code
        code == item_code
      else
        code.present?
      end
    end

    private

    def reset_link_attributes
      if linked_resource_type_changed? || item_type == "Container"
        self.linked_resource_id = nil
        self.destination = nil
        self.new_window = false

        self.linked_resource_type = "Aypex::Linkable::Uri" if item_type == "Container"
      end
    end

    def ensure_item_belongs_to_root
      if menu.try(:root).present? && parent_id.nil?
        self.parent = menu.root

        store_new_parent
      end
    end

    def touch_ancestors_and_menu
      ancestors.update_all(updated_at: Time.current)
      menu.try!(:touch)
    end

    def paremeterize_code
      return if code.blank?

      self.code = code.parameterize
    end
  end
end
