require "spec_helper"

module Aypex
  module Test
    Product = Struct.new(:url, keyword_init: true) do
      include ActiveModel::Validations

      validates :url, "aypex/url": true
    end
  end
end

describe Aypex::UrlValidator do
  describe "validating the given URL" do
    context "is invalid" do
      it { expect(Aypex::Test::Product.new(url: nil).valid?).to eq(false) }
      it { expect(Aypex::Test::Product.new(url: "").valid?).to eq(false) }
      it { expect(Aypex::Test::Product.new(url: "google.com").valid?).to eq(false) }
      it { expect(Aypex::Test::Product.new(url: "http:/google").valid?).to eq(false) }
      it { expect(Aypex::Test::Product.new(url: "www.google.com").valid?).to eq(false) }
    end

    context "is valid" do
      it { expect(Aypex::Test::Product.new(url: "http://google.com").valid?).to eq(true) }
      it { expect(Aypex::Test::Product.new(url: "https://google.com").valid?).to eq(true) }
      it { expect(Aypex::Test::Product.new(url: "http://www.google.com").valid?).to eq(true) }
      it { expect(Aypex::Test::Product.new(url: "https://www.google.com").valid?).to eq(true) }
      # Due to simplicity, this is valid even without tld
      it { expect(Aypex::Test::Product.new(url: "http://google").valid?).to eq(true) }
    end
  end

  describe "using a given message or a defined one" do
    let(:test_product) { Aypex::Test::Product.new(url: nil) }

    context "using the message option" do
      let(:message) { "is needed" }

      it "adds the given message to the record url errors array" do
        # Remove the validation set at the beginning
        Aypex::Test::Product.clear_validators!
        Aypex::Test::Product.validates(:url, "aypex/url": {message: message})

        test_product.valid?
        expect(test_product.errors.messages).to eq(url: [message])

        # Add back the validation removed previously
        Aypex::Test::Product.clear_validators!
        Aypex::Test::Product.validates(:url, "aypex/url": true)
      end
    end

    context "without using the message option" do
      it "adds a pre-defined message to the record url error array" do
        test_product.valid?
        expect(test_product.errors.messages).to eq(url: ["must be a valid URL"])
      end
    end
  end
end
