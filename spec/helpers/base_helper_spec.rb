require "spec_helper"

describe Aypex::BaseHelper do
  include described_class

  let(:current_store) { create(:store) }

  before do
    allow_any_instance_of(Aypex::BaseHelper).to receive(:current_locale).and_return("en")
    allow(controller).to receive(:controller_name).and_return("test")
  end

  context "available_countries" do
    let(:country) { create(:country) }

    before do
      create_list(:country, 3)
    end

    context "with checkout zone assigned to the store" do
      before do
        @zone = create(:zone, name: "No Limits", kind: "country")
        @zone.members.create(zoneable: country)
        current_store.update(checkout_zone_id: @zone.id)
      end

      it "return only the countries defined by the checkout_zone_id" do
        expect(available_countries).to eq([country])
        expect(current_store.checkout_zone_id).to eq @zone.id
      end
    end

    context "with no checkout zone defined" do
      before do
        current_store.update(checkout_zone_id: nil)
      end

      it "return complete list of countries" do
        expect(available_countries.count).to eq(Aypex::Country.count)
      end
    end
  end

  describe "#aypex_storefront_resource_url" do
    let!(:store) { create(:store) }
    let!(:category) { create(:category) }
    let!(:product) { create(:product) }

    before do
      allow(helper).to receive(:storefront_available?).and_return(false)
      allow(helper).to receive(:current_store).and_return(store)
      allow(helper).to receive(:locale_param)
    end

    context "for Product URL" do
      it { expect(helper.aypex_storefront_resource_url(product)).to eq("http://www.example.com/products/#{product.slug}") }

      context "when a locale is passed" do
        before do
          allow(helper).to receive(:current_store).and_return(store)
        end

        it { expect(helper.aypex_storefront_resource_url(product, locale: :de)).to eq("http://www.example.com/de/products/#{product.slug}") }
      end

      context "when locale_param is present" do
        before do
          allow(helper).to receive(:locale_param).and_return(:fr)
        end

        it { expect(helper.aypex_storefront_resource_url(product)).to eq("http://www.example.com/fr/products/#{product.slug}") }
      end
    end

    context "for Category URL" do
      it { expect(helper.aypex_storefront_resource_url(category)).to eq("http://www.example.com/t/#{category.permalink}") }

      context "when a locale is passed" do
        it { expect(helper.aypex_storefront_resource_url(category, locale: :de)).to eq("http://www.example.com/de/t/#{category.permalink}") }
      end

      context "when locale_param is present" do
        before do
          allow(helper).to receive(:locale_param).and_return(:fr)
        end

        it { expect(helper.aypex_storefront_resource_url(category)).to eq("http://www.example.com/fr/t/#{category.permalink}") }
      end
    end
  end

  context "link_to_tracking" do
    it "returns tracking link if available" do
      a = link_to_tracking_html(shipping_method: true, tracking: "123", tracking_url: "http://g.c/?t=123").css("a")

      expect(a.text).to eq "123"
      expect(a.attr("href").value).to eq "http://g.c/?t=123"
    end

    it "returns tracking without link if link unavailable" do
      html = link_to_tracking_html(shipping_method: true, tracking: "123", tracking_url: nil)
      expect(html.css("span").text).to eq "123"
    end

    it "returns nothing when no shipping method" do
      html = link_to_tracking_html(shipping_method: nil, tracking: "123")
      expect(html.css("span").text).to eq ""
    end

    it "returns nothing when no tracking" do
      html = link_to_tracking_html(tracking: nil)
      expect(html.css("span").text).to eq ""
    end

    def link_to_tracking_html(options = {})
      node = link_to_tracking(double(:shipment, options))
      Nokogiri::HTML(node.to_s)
    end
  end

  context "base_cache_key" do
    let(:current_currency) { "USD" }

    context "when try_aypex_current_user defined" do
      before do
        I18n.locale = I18n.default_locale
        allow_any_instance_of(described_class).to receive(:try_aypex_current_user).and_return(user)
      end

      context "when admin user" do
        let!(:user) { create(:admin_user) }

        it "returns base cache key" do
          expect(base_cache_key).to eq [:en, "USD", true, true]
        end
      end

      context "when user without admin role" do
        let!(:user) { create(:user) }

        it "returns base cache key" do
          expect(base_cache_key).to eq [:en, "USD", true, false]
        end
      end

      context "when aypex_current_user is nil" do
        let!(:user) { nil }

        it "returns base cache key" do
          expect(base_cache_key).to eq [:en, "USD", false, nil]
        end
      end
    end

    context "when try_aypex_current_user is undefined" do
      let(:current_currency) { "USD" }

      before { I18n.locale = I18n.default_locale }

      it "returns base cache key" do
        expect(base_cache_key).to eq [:en, "USD", nil, nil]
      end
    end
  end

  # Regression test for #2396
  context "meta_data_tags" do
    it "truncates a product description to 160 characters" do
      # Because the controller_name method returns "test"
      # controller_name is used by this method to infer what it is supposed
      # to be generating meta_data_tags for
      text = FFaker::Lorem.paragraphs(2).join(" ")
      @test = Aypex::Product.new(description: text, stores: [current_store])
      tags = Nokogiri::HTML.parse(meta_data_tags)
      content = tags.css("meta[name=description]").first["content"]
      assert content.length <= 160, "content length is not truncated to 160 characters"
    end
  end

  context "og_meta_data_tags" do
    let(:current_currency) { "USD" }
    let(:image) { create(:image, position: 1) }
    let(:product) do
      create(:product, stores: [current_store]).tap { |product| product.images << image }
    end

    it "renders open graph meta data tags for PDP" do
      # Because the controller_name method returns "test"
      # controller_name is used by this method to infer what it is supposed
      # to be generating og_meta_data_tags for
      @test = product
      tags = Nokogiri::HTML.parse(og_meta_data_tags)

      meta_image = tags.css('meta[property="og:image"]').first["content"]
      meta_type = tags.css('meta[property="og:type"]').first["content"]
      meta_title = tags.css('meta[property="og:title"]').first["content"]
      meta_description = tags.css('meta[property="og:description"]').first["content"]
      meta_price_amount = tags.css('meta[property="product:price:amount"]').first["content"]
      meta_price_currency = tags.css('meta[property="product:price:currency"]').first["content"]

      expect(meta_image).to be_present

      expect(meta_type).to eq("product")
      expect(meta_title).to eq(product.name)
      expect(meta_description).to eq(product.description)

      default_price = product.master.default_price
      expect(meta_price_amount).to eq(default_price.amount.to_s)
      expect(meta_price_currency).to eq(default_price.currency)
    end
  end

  # Regression test for #5384

  context "pretty_time" do
    it "prints in a format" do
      time = Time.new(2012, 5, 6, 13, 33)
      expect(pretty_time(time)).to eq "May 06, 2012  1:33 PM #{time.zone}"
    end

    it "return empty string when nil is supplied" do
      expect(pretty_time(nil)).to eq ""
    end
  end

  context "pretty_date" do
    it "prints in a format" do
      expect(pretty_date(Time.new(2012, 5, 6, 13, 33))).to eq "May 06, 2012"
    end

    it "return empty string when nil is supplied" do
      expect(pretty_date(nil)).to eq ""
    end
  end

  describe "#display_price" do
    let!(:product) { create(:product, stores: [current_store]) }
    let(:current_currency) { "USD" }
    let(:current_price_options) { {tax_zone: current_tax_zone} }

    context "when there is no current order" do
      let(:current_tax_zone) { nil }

      it "returns the price including default vat" do
        expect(display_price(product)).to eq("$19.99")
      end

      context "with a default VAT" do
        let(:current_tax_zone) { create(:zone_with_country, default_tax: true) }
        let!(:tax_rate) do
          create(:tax_rate,
            included_in_price: true,
            zone: current_tax_zone,
            tax_category: product.tax_category,
            amount: 0.2)
        end

        it "returns the price adding the VAT" do
          expect(display_price(product)).to eq("$19.99")
        end
      end
    end

    context "with an order that has a tax zone" do
      let(:current_tax_zone) { create(:zone_with_country) }
      let(:current_order) { Aypex::Order.new }
      let(:default_zone) { create(:zone_with_country, default_tax: true) }

      let!(:default_vat) do
        create(:tax_rate,
          included_in_price: true,
          zone: default_zone,
          tax_category: product.tax_category,
          amount: 0.2)
      end

      context "that matches no VAT" do
        it "returns the price excluding VAT" do
          expect(display_price(product)).to eq("$16.66")
        end
      end

      context "that matches a VAT" do
        let!(:other_vat) do
          create(:tax_rate,
            included_in_price: true,
            zone: current_tax_zone,
            tax_category: product.tax_category,
            amount: 0.4)
        end

        it "returns the price adding the VAT" do
          expect(display_price(product)).to eq("$23.32")
        end
      end
    end
  end

  describe "#aypex_png_icon_path" do
    context "when a store has no default square logo" do
      let(:current_store) { create(:store, :with_icon) }

      it "returns a square png" do
        expect(aypex_png_icon_path).to end_with("square.png")
      end

      it "returns the full url host present" do
        expect(URI.parse(aypex_png_icon_path).host).to be_present
      end
    end

    context "when a store has no favicon" do
      it do
        expect(aypex_png_icon_path).to be_nil
      end
    end
  end
end
