module Aypex
  module LocaleHelper
    require "twitter_cldr"

    def all_locales_options(set_locale = nil)
      supported_locales_for_all_stores.map { |locale| locale_presentation(locale, set_locale) }
    end

    def available_locales_options(set_locale = nil)
      available_locales.map { |locale| locale_presentation(locale, set_locale) }
    end

    def supported_locales_options(set_locale = nil)
      return if current_store.nil?

      current_store.supported_locales_list.map { |locale| locale_presentation(locale, set_locale) }
    end

    def locale_presentation(locale, set_locale = nil)
      formatted_locale = locale.to_s
      [localized_language_name(formatted_locale, set_locale), formatted_locale]
    end

    def locale_full_name(locale)
      I18n.t("aypex.i18n.this_file_language", locale: locale)
    end

    def should_render_locale_dropdown?
      return false if current_store.nil?

      current_store.supported_locales_list.size > 1
    end

    ##
    # Returns a locales language name in its native language, or a specified language.
    # The first argument passed is the locale of the language name that you require.
    # The optional second argument is the language you require the language name returning in.
    # If no second argument is passed, the language name will be returned in its native language.
    # Arguments should be of the type Symbol or String.
    #
    # Example:
    #
    #   localized_language_name('de') # => 'Deutsch (de)'
    #   localized_language_name(:en) # => 'English (en)'
    #   localized_language_name('de', 'en') # => 'German (de)'
    #   localized_language_name(:en, :de) # => 'Englisch (en)'
    #
    #   # An unsupported locale returns the locale in braces
    #   localized_language_name('xx-XX') #=> '(xx-XX)'
    #
    def localized_language_name(locale, set_locale = nil)
      last_resort_locale = locale.to_s.slice(0..1).to_sym
      locale_as_sym = TwitterCldr.convert_locale(locale).to_sym
      used_locale = if set_locale
        TwitterCldr.convert_locale(set_locale).to_sym
      else
        locale_as_sym
      end

      if I18n.exists?("aypex.language_name_overide.#{locale}", locale: used_locale.to_s, fallback: false)
        return I18n.t("aypex.language_name_overide.#{locale}", locale: used_locale.to_s)
      end

      lang_name = locale_as_sym.localize(used_locale).as_language_code || last_resort_locale.localize(used_locale).as_language_code

      "#{lang_name.to_s.capitalize} (#{locale})".strip
    end
  end
end
