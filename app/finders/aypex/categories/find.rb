module Aypex
  module Categories
    class Find
      def initialize(scope:, params:)
        @scope = scope
        @ids = String(params.dig(:filter, :ids)).split(",")
        @parent = params.dig(:filter, :parent_id)
        @parent_permalink = params.dig(:filter, :parent_permalink)
        @base_category = params.dig(:filter, :base_category_id)
        @name = params.dig(:filter, :name)
        @roots = params.dig(:filter, :roots)
      end

      def execute
        categories = by_ids(scope)
        categories = by_parent(categories)
        categories = by_parent_permalink(categories)
        categories = by_base_category(categories)
        categories = by_roots(categories)
        categories = by_name(categories)

        categories.distinct
      end

      private

      attr_reader :ids, :parent, :parent_permalink, :base_category, :roots, :name, :scope

      def ids?
        ids.present?
      end

      def parent?
        parent.present?
      end

      def parent_permalink?
        parent_permalink.present?
      end

      def base_category?
        base_category.present?
      end

      def roots?
        roots.present?
      end

      def name?
        name.present?
      end

      def name_matcher
        Aypex::Category.arel_table[:name].matches("%#{name}%")
      end

      def by_ids(categories)
        return categories unless ids?

        categories.where(id: ids)
      end

      def by_parent(categories)
        return categories unless parent?

        categories.where(parent_id: parent)
      end

      def by_parent_permalink(categories)
        return categories unless parent_permalink?

        categories.joins(:parent).where(parent: {permalink: parent_permalink})
      end

      def by_base_category(categories)
        return categories unless base_category?

        categories.where(base_category_id: base_category)
      end

      def by_roots(categories)
        return categories unless roots?

        categories.roots
      end

      def by_name(categories)
        return categories unless name?

        categories.where(name_matcher)
      end
    end
  end
end
