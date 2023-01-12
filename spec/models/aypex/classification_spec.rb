require "spec_helper"

module Aypex
  describe Classification do
    let(:store) { create(:store) }

    # Regression test for #3494
    let(:category_with_5_products) do
      products = []
      5.times do
        products << create(:base_product, stores: [store])
      end

      create(:category, products: products)
    end

    it "cannot link the same category to the same product more than once" do
      product = create(:product, stores: [store])
      category = create(:category)
      expect { product.categories << category }.not_to raise_error
      expect { product.categories << category }.to raise_error(ActiveRecord::RecordInvalid)
    end

    def positions_to_be_valid(category)
      positions = category.reload.classifications.map(&:position)
      expect(positions).to eq((1..category.classifications.count).to_a)
    end

    it "has a valid fixtures" do
      expect positions_to_be_valid(category_with_5_products)
      expect(Aypex::Classification.count).to eq 5
    end

    context "removing product from category" do
      before do
        p = category_with_5_products.products[1]
        expect(p.classifications.first.position).to eq(2)
        category_with_5_products.products.destroy(p)
      end

      it "resets positions" do
        expect positions_to_be_valid(category_with_5_products)
      end
    end

    context "replacing category's products" do
      before do
        products = category_with_5_products.products.to_a
        products.pop(1)
        category_with_5_products.products = products
        category_with_5_products.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(category_with_5_products)
      end
    end

    context "removing category from product" do
      before do
        p = category_with_5_products.products[1]
        p.categories.destroy(category_with_5_products)
        p.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(category_with_5_products)
      end
    end

    context "replacing product's categories" do
      before do
        p = category_with_5_products.products[1]
        p.categories = []
        p.save!
      end

      it "resets positions" do
        expect positions_to_be_valid(category_with_5_products)
      end
    end

    context "destroying classification" do
      before do
        classification = category_with_5_products.classifications[1]
        classification.destroy
      end

      it "resets positions" do
        expect positions_to_be_valid(category_with_5_products)
      end
    end
  end
end
