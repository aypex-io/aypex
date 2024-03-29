require "spec_helper"

module Aypex
  describe Aypex::ProductDuplicator do
    let(:store) { create(:store) }
    let!(:product_property) { create(:product_property, product: product) }
    let!(:product) { create(:product, stores: [store]) }
    let!(:duplicator) { Aypex::ProductDuplicator.new(product) }

    let(:file) { File.open(File.expand_path("../../fixtures/files/square.jpg", __dir__)) }
    let(:params) do
      {
        viewable_id: product.id,
        viewable_type: "Aypex::Product",
        alt: "position 1",
        position: 1
      }
    end

    before do
      new_image = Aypex::Asset::Validate::Image.new(params)
      new_image.attachment.attach(io: file, filename: File.basename(file))
      new_image.save!
    end

    it "will duplicate the product" do
      expect { duplicator.duplicate }.to change { Aypex::Product.count }.by(1)
    end

    it "will duplicate already duplicated product" do
      Timecop.scale(3600)
      expect { 3.times { duplicator.duplicate } }.to change { Aypex::Product.count }.by(3)
      Timecop.return
    end

    context "when image duplication enabled" do
      it "will duplicate the product images" do
        expect { duplicator.duplicate }.to change { Aypex::Asset::Validate::Image.count }.by(1)
      end
    end

    context "when image duplication disabled" do
      let!(:duplicator) { Aypex::ProductDuplicator.new(product, false) }

      it "will not duplicate the product images" do
        expect { duplicator.duplicate }.not_to change { Aypex::Asset::Validate::Image.count }
      end
    end

    context "image duplication default" do
      context "when default is set to true" do
        it "clones images if no flag passed to initializer" do
          expect { duplicator.duplicate }.to change { Aypex::Asset::Validate::Image.count }.by(1)
        end
      end

      context "when default is set to false" do
        before do
          ProductDuplicator.clone_images_default = false
        end

        after do
          ProductDuplicator.clone_images_default = true
        end

        it "does not clone images if no flag passed to initializer" do
          expect { ProductDuplicator.new(product).duplicate }.not_to change { Aypex::Asset::Validate::Image.count }
        end
      end
    end

    context "product attributes" do
      let!(:new_product) { duplicator.duplicate }

      it "will set an unique name" do
        expect(new_product.name).to eql "COPY OF #{product.name}"
      end

      it "will set an unique sku" do
        expect(new_product.sku).to include "COPY OF SKU"
      end

      it "copied the properties" do
        expect(new_product.product_properties.count).to eq 1
        expect(new_product.product_properties.first.property.name).to eql product_property.property.name
      end
    end

    context "stores" do
      let!(:new_product) { duplicator.duplicate }

      it { expect(new_product.stores).to eq [store] }
    end

    context "with variants" do
      let(:option_type) { create(:option_type, name: "MyOptionType") }
      let(:option_value1) { create(:option_value, name: "OptionValue1", option_type: option_type) }
      let(:option_value2) { create(:option_value, name: "OptionValue2", option_type: option_type) }

      let!(:variant1) { create(:variant, product: product, option_values: [option_value1]) }
      let!(:variant2) { create(:variant, product: product, option_values: [option_value2]) }

      it "will duplicate the variants" do
        # will change the count by 3, since there will be a master variant as well
        expect { duplicator.duplicate }.to change { Aypex::Variant.count }.by(3)
      end

      it "will not duplicate the option values" do
        expect { duplicator.duplicate }.not_to change { Aypex::OptionValue.count }
      end
    end
  end
end
