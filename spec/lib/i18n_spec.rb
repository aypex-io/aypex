require "rspec/expectations"
require "i18n"
require "testing_support/i18n"
require "spec_helper"

describe "i18n" do
  before do
    I18n.backend.store_translations(:en,
      aypex: {
        foo: "bar",
        bar: {
          foo: "bar within bar scope",
          invalid: nil,
          legacy_translation: "back in the day..."
        },
        invalid: nil,
        legacy_translation: "back in the day..."
      })
  end

  describe "#available_locales" do
    context "when AypexI18n is defined" do
      before do
        class_double("AypexI18n")
          .as_stubbed_const(transfer_nested_constants: true)
        class_double("AypexI18n::Locale", all: ["en", :en, :de, :nl]).as_stubbed_const(transfer_nested_constants: true)
      end

      it "returns all locales from the AypexI18n" do
        locales = Aypex.available_locales
        expected_locales = [:en, :de, :nl, :ar, :az, :bg, :ca, :cs, :da, :el, :es, :fa, :fi, :fr, :hu, :id, :it, :ja, :"pt-BR", :ro, :ru, :sk, :sv, :tr, :"zh-CN", :"zh-TW", :pl, :uk, :vi]

        expect(locales).to match_array(expected_locales)
      end

      it 'returns an array with the string "en" removed' do
        locales = Aypex.available_locales

        expect(locales).not_to include("en")
      end
    end

    context "when AypexI18n is not defined" do
      it "returns just default locales" do
        locales = Aypex.available_locales

        expected_locales = [:en, :ar, :az, :bg, :ca, :cs, :da, :de, :el, :es, :fa, :fi, :fr, :hu, :id, :it, :ja, :nl, :"pt-BR", :ro, :ru, :sv, :sk, :tr, :"zh-CN", :"zh-TW", :pl, :uk, :vi]

        expect(locales).to match_array(expected_locales)
      end
    end
  end

  it "translates within the aypex scope" do
    expect(Aypex.normal_t(:foo)).to eql("bar")
    expect(Aypex.translate(:foo)).to eql("bar")
  end

  it "raise error without any context when using a path" do
    expect do
      Aypex.normal_t(".legacy_translation")
    end.to raise_error(StandardError)

    expect do
      Aypex.translate(".legacy_translation")
    end.to raise_error(StandardError)
  end

  it "prepends a string scope" do
    expect(Aypex.normal_t(:foo, scope: "bar")).to eql("bar within bar scope")
  end

  it "prepends to an array scope" do
    expect(Aypex.normal_t(:foo, scope: ["bar"])).to eql("bar within bar scope")
  end

  it "returns two translations" do
    expect(Aypex.normal_t([:foo, "bar.foo"])).to eql(["bar", "bar within bar scope"])
  end

  it "returns reasonable string for missing translations" do
    expect(Aypex.t(:missing_entry)).to include("<span")
  end

  context "missed + unused translations" do
    def key_with_locale(key)
      "#{key} (#{I18n.locale})"
    end

    before do
      Aypex.used_translations = []
    end

    context "missed translations" do
      def assert_missing_translation(key)
        key = key_with_locale(key)
        message = Aypex.missing_translation_messages.detect { |m| m == key }
        expect(message).not_to(be_nil, "expected '#{key}' to be missing, but it wasn't.")
      end

      it "logs missing translations" do
        Aypex.t(:missing, scope: [:else, :where])
        Aypex.check_missing_translations
        assert_missing_translation("else")
        assert_missing_translation("else.where")
        assert_missing_translation("else.where.missing")
      end

      it "does not log present translations" do
        Aypex.t(:foo)
        Aypex.check_missing_translations
        expect(Aypex.missing_translation_messages).to be_empty
      end

      it "does not break when asked for multiple translations" do
        Aypex.t [:foo, "bar.foo"]
        Aypex.check_missing_translations
        expect(Aypex.missing_translation_messages).to be_empty
      end
    end

    context "unused translations" do
      def assert_unused_translation(key)
        key = key_with_locale(key)
        message = Aypex.unused_translation_messages.detect { |m| m == key }
        expect(message).not_to(be_nil, "expected '#{key}' to be unused, but it was used.")
      end

      def assert_used_translation(key)
        key = key_with_locale(key)
        message = Aypex.unused_translation_messages.detect { |m| m == key }
        expect(message).to(be_nil, "expected '#{key}' to be used, but it wasn't.")
      end

      it "logs translations that aren't used" do
        Aypex.check_unused_translations
        assert_unused_translation("bar.legacy_translation")
        assert_unused_translation("legacy_translation")
      end

      it "does not log used translations" do
        Aypex.t(:foo)
        Aypex.check_unused_translations
        assert_used_translation("foo")
      end
    end
  end
end
