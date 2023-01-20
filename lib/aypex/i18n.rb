require "i18n"
require "active_support/core_ext/array/extract_options"
require "action_view"

module Aypex
  class TranslationHelperWrapper
    include ActionView::Helpers::TranslationHelper
  end

  class << self
    # Add aypex namespace and delegate to Rails TranslationHelper for some nice
    # extra functionality. e.g return reasonable strings for missing translations
    def translate(key, options = {})
      options[:scope] = [*options[:scope]].unshift(:aypex).uniq

      TranslationHelperWrapper.new.translate(key, **options)
    end
    alias_method :t, :translate

    def available_locales
      locales_from_i18n = I18n.available_locales
      locales =
        if defined?(AypexI18n)
          (AypexI18n::Locale.all << :en).map(&:to_sym)
        else
          [Rails.application.config.i18n.default_locale, I18n.locale, :en]
        end

      (locales + locales_from_i18n).uniq.compact
    end
  end
end
