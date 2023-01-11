module Aypex
  module BaseHelper
    def available_countries
      countries = current_store.countries_available_for_checkout

      countries.collect do |country|
        country.name = Aypex.t(country.iso, scope: "country_names", default: country.name)
        country
      end.sort_by { |c| c.name.parameterize }
    end

    def all_countries
      countries = Aypex::Country.all

      countries.collect do |country|
        country.name = Aypex.t(country.iso, scope: "country_names", default: country.name)
        country
      end.sort_by { |c| c.name.parameterize }
    end

    def aypex_resource_path(resource)
      last_word = resource.class.name.split("::", 10).last

      aypex_class_name_as_path(last_word)
    end

    def aypex_class_name_as_path(class_name)
      class_name.underscore.humanize.parameterize(separator: "_")
    end

    def display_price(product_or_variant)
      product_or_variant
        .price_in(current_currency)
        .display_price_including_vat_for(current_price_options)
        .to_html
    end

    def display_compare_at_price(product_or_variant)
      product_or_variant
        .price_in(current_currency)
        .display_compare_at_price_including_vat_for(current_price_options)
        .to_html
    end

    def link_to_tracking(shipment, options = {})
      return unless shipment.tracking && shipment.shipping_method

      options[:target] ||= :blank

      if shipment.tracking_url
        link_to(shipment.tracking, shipment.tracking_url, options)
      else
        content_tag(:span, shipment.tracking)
      end
    end

    def aypex_favicon_path
      if current_store.favicon.present?
        main_app.cdn_image_url(current_store.favicon)
      else
        url_for("favicon.ico")
      end
    end

    def object
      instance_variable_get("@" + controller_name.singularize)
    end

    def og_meta_data
      og_meta = {}

      if object.is_a? Aypex::Product
        image = default_image_for_product_or_variant(object)
        og_meta["og:image"] = main_app.cdn_image_url(image.attachment) if image&.attachment

        og_meta["og:url"] = aypex.url_for(object) if storefront_available? # url_for product needed
        og_meta["og:type"] = object.class.name.demodulize.downcase
        og_meta["og:title"] = object.name
        og_meta["og:description"] = object.description

        price = object.price_in(current_currency)
        if price
          og_meta["product:price:amount"] = price.amount
          og_meta["product:price:currency"] = current_currency
        end
      end

      og_meta
    end

    def meta_data
      meta = {}

      if object.is_a? ApplicationRecord
        meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
        meta[:description] = object.meta_description if object[:meta_description].present?
      end

      if meta[:description].blank? && object.is_a?(Aypex::Product)
        meta[:description] = truncate(strip_tags(object.description), length: 160, separator: " ")
      end

      if meta[:keywords].blank? || meta[:description].blank?
        if object && object[:name].present?
          meta.reverse_merge!(keywords: [object.name, current_store.meta_keywords].reject(&:blank?).join(", "),
            description: [object.name, current_store.meta_description].reject(&:blank?).join(", "))
        else
          meta.reverse_merge!(keywords: (current_store.meta_keywords || current_store.seo_title),
            description: (current_store.homepage(I18n.locale)&.seo_meta_description || current_store.seo_meta_description))
        end
      end
      meta
    end

    def og_meta_data_tags
      og_meta_data.map do |property, content|
        tag("meta", property: property, content: content) unless property.nil? || content.nil?
      end.join("\n")
    end

    def meta_data_tags
      meta_data.map do |name, content|
        tag("meta", name: name, content: content) unless name.nil? || content.nil?
      end.join("\n")
    end

    def pretty_time(time)
      return "" if time.blank?

      [I18n.l(time.to_date, format: :long), time.strftime("%l:%M %p %Z")].join(" ")
    end

    def pretty_date(date)
      return "" if date.blank?

      [I18n.l(date.to_date, format: :long)].join(" ")
    end

    def seo_url(taxon, options = {})
      aypex.nested_taxons_path(taxon.permalink, options.merge(locale: locale_param))
    end

    def storefront_available?
      Aypex::Engine.storefront_available?
    end

    def aypex_storefront_resource_url(resource, options = {})
      if defined?(locale_param) && locale_param.present?
        options[:locale] = locale_param
      end

      localize = if options[:locale].present?
        "/#{options[:locale]}"
      else
        ""
      end

      if resource.instance_of?(Aypex::Product)
        "#{current_store.formatted_url + localize}/#{Aypex::Config.storefront_products_path}/#{resource.slug}"
      elsif resource.instance_of?(Aypex::Taxon)
        "#{current_store.formatted_url + localize}/#{Aypex::Config.storefront_taxons_path}/#{resource.permalink}"
      elsif resource.instance_of?(Aypex::Cms::Pages::FeaturePage) || resource.instance_of?(Aypex::Cms::Pages::StandardPage)
        "#{current_store.formatted_url + localize}/#{Aypex::Config.storefront_pages_path}/#{resource.slug}"
      elsif localize.blank?
        current_store.formatted_url
      else
        current_store.formatted_url + localize
      end
    end

    # we should always try to render image of the default variant
    # same as it's done on PDP
    def default_image_for_product(product)
      if product.images.any?
        product.images.first
      elsif product.default_variant.images.any?
        product.default_variant.images.first
      elsif product.variant_images.any?
        product.variant_images.first
      end
    end

    def default_image_for_product_or_variant(product_or_variant)
      Rails.cache.fetch("aypex/default-image/#{product_or_variant.cache_key_with_version}") do
        if product_or_variant.is_a?(Aypex::Product)
          default_image_for_product(product_or_variant)
        elsif product_or_variant.is_a?(Aypex::Variant)
          if product_or_variant.images.any?
            product_or_variant.images.first
          else
            default_image_for_product(product_or_variant.product)
          end
        end
      end
    end

    def base_cache_key
      [I18n.locale, current_currency, defined?(try_aypex_current_user) && try_aypex_current_user.present?,
        defined?(try_aypex_current_user) && try_aypex_current_user.try(:has_aypex_role?, "admin")]
    end

    def maximum_quantity
      Aypex::DatabaseTypeUtilities.maximum_value_for(:integer)
    end

    private

    def meta_robots
      return unless current_store.respond_to?(:seo_robots)
      return if current_store.seo_robots.blank?

      tag("meta", name: "robots", content: current_store.seo_robots)
    end
  end
end
