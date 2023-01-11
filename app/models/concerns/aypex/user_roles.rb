module Aypex
  module UserRoles
    extend ActiveSupport::Concern

    included do
      has_many :role_users, class_name: "Aypex::RoleUser", foreign_key: :user_id, dependent: :destroy
      has_many :aypex_roles, through: :role_users, class_name: "Aypex::Role", source: :role

      scope :aypex_admin, -> { joins(:aypex_roles).where(Aypex::Role.table_name => {name: "admin"}) }

      # has_aypex_role? simply needs to return true or false whether a user has a role or not.
      def has_aypex_role?(role_name)
        aypex_roles.exists?(name: role_name)
      end

      def self.admin
        ActiveSupport::Deprecation.warn("`User#admin` is deprecated and will be removed in Aypex 5. Please use `User#aypex_admin`")

        aypex_admin
      end

      def self.admin_created?
        ActiveSupport::Deprecation.warn("`User#admin_created?` is deprecated and will be removed in Aypex 5. Please use `User#aypex_admin_created?`")

        aypex_admin_created?
      end

      def admin?
        ActiveSupport::Deprecation.warn("`User#admin?` is deprecated and will be removed in Aypex 5. Please use `User#aypex_admin?`")

        aypex_admin?
      end

      def self.aypex_admin_created?
        aypex_admin.exists?
      end

      def aypex_admin?
        has_aypex_role?("admin")
      end
    end
  end
end
