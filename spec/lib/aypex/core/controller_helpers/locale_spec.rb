require "spec_helper"

class FakesController < ApplicationController
  include Aypex::ControllerHelpers::Auth
  include Aypex::ControllerHelpers::Order
  include Aypex::ControllerHelpers::Store
  include Aypex::ControllerHelpers::Locale
end

class FakesControllerWithLocale < FakesController
  def config_locale
    "en"
  end
end

describe Aypex::ControllerHelpers::Locale, type: :controller do
  controller(FakesController) {}

  let(:user) { build(:user, selected_locale: "pl") }

  before { allow(controller).to receive(:aypex_current_user).and_return(user) }

  describe "#current_locale" do
    context "taking locale from user and store with locale set" do
      let!(:store) { create(:store, default: true, default_locale: "fr", supported_locales: "fr,de,pl") }

      before { store.use_the_user_preferred_locale = true }

      it "returns locale set within user" do
        expect(controller.current_locale.to_s).to eq("pl")
      end
    end

    context "not taking locale from user" do
      context "store with locale set" do
        let!(:store) { create(:store, default: true, default_locale: "fr", supported_locales: "fr,de") }

        before { store.use_the_user_preferred_locale = false }

        it "returns current store default locale" do
          expect(controller.current_locale.to_s).to eq("fr")
        end

        it "return supported locale when passed as param" do
          controller.params = {locale: "de"}
          expect(controller.current_locale.to_s).to eq("de")
        end
      end

      context "config_locale present" do
        controller(FakesControllerWithLocale) {}

        let!(:store) { create(:store, default: true, default_locale: "fr") }

        it "returns config_locale if present" do
          expect(controller.current_locale.to_s).to eq("en")
        end
      end

      context "store without locale set" do
        let!(:store) { create(:store, default: true, default_locale: nil) }

        context "without I18n.default_locale set" do
          it "fallbacks to english" do
            expect(controller.current_locale.to_s).to eq("en")
          end
        end

        context "with I18n.default_locale set" do
          before { I18n.default_locale = :de }

          after { I18n.default_locale = :en }

          it "fallbacks to the default application locale" do
            expect(controller.current_locale.to_s).to eq("de")
          end
        end
      end
    end
  end

  describe "#supported_locales" do
    let!(:store) { create(:store, default: true, default_locale: "de", supported_locales: "de, pl") }

    it "returns supported currencies" do
      expect(controller.supported_locales.to_s).to include("de")
    end

    it "returns supported locales" do
      expect(controller.supported_locales.to_s).to include("pl")
    end
  end

  describe "#locale_param" do
    let!(:store) { create(:store, default: true, default_locale: "en", supported_locales: "en,de,fr") }

    context "same as store default locale" do
      before { I18n.locale = :en }

      it { expect(controller.locale_param).to eq(nil) }
    end

    context "different than store locale" do
      before { I18n.locale = :de }

      after { I18n.locale = :en }

      it { expect(controller.locale_param).to eq("de") }
    end
  end
end
