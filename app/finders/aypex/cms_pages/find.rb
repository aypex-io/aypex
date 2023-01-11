module Aypex
  module CmsPages
    class Find < ::Aypex::BaseFinder
      ALLOWED_KINDS = %w[standard home feature].freeze

      def initialize(scope:, params:)
        @scope = scope
        @title = params.dig(:filter, :title)
        @kind = params.dig(:filter, :type)
      end

      def execute
        pages = by_title(scope)
        by_kind(pages)
      end

      private

      attr_reader :scope, :title, :kind

      def title_matcher
        Aypex::CmsPage.arel_table[:title].matches("%#{title}%")
      end

      def by_title(pages)
        return pages if title.blank?

        pages.where(title_matcher)
      end

      def by_kind(pages)
        return pages if kind.blank?
        return pages if ALLOWED_KINDS.exclude?(kind)

        pages.send(kind)
      end
    end
  end
end
