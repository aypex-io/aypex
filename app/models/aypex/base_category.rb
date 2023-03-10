module Aypex
  class BaseCategory < Aypex::Base
    include Metadata
    include Aypex::Webhooks::HasWebhooks if defined?(Aypex::Webhooks)

    acts_as_list

    validates :name, presence: true, uniqueness: {case_sensitive: false, allow_blank: true, scope: :store_id}
    validates :store, presence: true

    has_many :categories, inverse_of: :base_category
    has_one :root, -> { where parent_id: nil }, class_name: "Aypex::Category", dependent: :destroy
    belongs_to :store, class_name: "Aypex::Store"

    after_create :set_root
    after_update :set_root_category_name

    default_scope { order("#{table_name}.position, #{table_name}.created_at") }

    self.whitelisted_ransackable_associations = %w[root]

    private

    def set_root
      self.root ||= Category.create!(base_category_id: id, name: name)
    end

    def set_root_category_name
      return unless saved_change_to_name?
      return if name.to_s == root.name.to_s

      root.update(name: name)
    end
  end
end
