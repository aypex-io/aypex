require "spec_helper"

module Aypex
  describe Products::Find do
    let!(:product) { create(:product, price: 15.99) }
    let!(:product_2) { create(:product, discontinue_on: Time.current + 1.day, price: 23.99) }
    let!(:product_3) { create(:variant, price: 19.99).product }
    let!(:option_value) { create(:option_value) }
    let!(:deleted_product) { create(:product, deleted_at: Time.current - 1.day) }
    let!(:discontinued_product) { create(:product, status: "archived") }
    let!(:in_stock_product) { create(:product_in_stock) }
    let!(:not_backorderable_product) { create(:product_in_stock, :without_backorder) }
    let(:store) { product.stores.first }

    context "include discontinued" do
      it "returns products with discontinued" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            currency: "USD",
            categories: "",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: false,
            show_discontinued: true,
            in_stock: false
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(product, product_2, product_3, discontinued_product, in_stock_product, not_backorderable_product)
      end
    end

    context "include deleted" do
      it "returns products with deleted" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            categories: "",
            currency: "USD",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: true,
            show_discontinued: false,
            in_stock: false
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(product, product_2, product_3, deleted_product, in_stock_product, not_backorderable_product)
      end
    end

    context "in stock" do
      it "returns products with variants in stock" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            categories: "",
            currency: "USD",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: false,
            show_discontinued: false,
            in_stock: true
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(in_stock_product, not_backorderable_product)
      end
    end

    context "backorderable" do
      it "returns products with backorderable variants" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            categories: "",
            currency: "USD",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: false,
            show_discontinued: false,
            in_stock: false,
            backorderable: true
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(product, product_2, product_3, in_stock_product) # No not_backorderable_product.
      end
    end

    context "purchasable" do
      it "returns products with purchasable variants" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            categories: "",
            currency: "USD",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: false,
            show_discontinued: false,
            in_stock: false,
            backorderable: false,
            purchasable: true
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(product, product_2, product_3, in_stock_product, not_backorderable_product)
      end
    end

    context "exclude discontinued and deleted" do
      it "returns not discontinued and not deleted products" do
        params = {
          filter: {
            ids: "",
            skus: "",
            price: "",
            currency: "USD",
            categories: "",
            concat_categories: "",
            name: false,
            options: false,
            show_deleted: false,
            show_discontinued: false,
            in_stock: false
          }
        }

        expect(
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        ).to contain_exactly(product, product_2, product_3, in_stock_product, not_backorderable_product)
      end
    end

    describe "filter by options and option values" do
      subject(:products) do
        described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute
      end

      let(:option_type_1) { create(:option_type, name: "size") }
      let(:option_type_2) { create(:option_type, name: "state") }

      let(:option_value_1_1) { create(:option_value, option_type: option_type_1, name: "s", presentation: "S") }
      let(:option_value_1_2) { create(:option_value, option_type: option_type_1, name: "m", presentation: "M") }
      let(:option_value_2_1) { create(:option_value, option_type: option_type_2, name: "old", presentation: "Old") }
      let(:option_value_2_2) { create(:option_value, option_type: option_type_2, name: "new", presentation: "New") }

      let(:product_1) { create(:product, option_types: [option_type_1, option_type_2]) }
      let(:product_2) { create(:product, option_types: [option_type_1, option_type_2]) }
      let(:product_3) { create(:product, option_types: [option_type_1, option_type_2]) }

      let!(:variant_1) { create(:variant, product: product_1, option_values: [option_value_1_1, option_value_2_1]) }
      let!(:variant_2) { create(:variant, product: product_2, option_values: [option_value_1_2, option_value_2_2]) }
      let!(:variant_3) { create(:variant, product: product_3, option_values: [option_value_1_1, option_value_2_2]) }

      context "for options" do
        let(:params) do
          {
            filter: {
              options: ActionController::Parameters.new(
                size: "s",
                state: "old"
              )
            }
          }
        end

        it "returns products matching all given options" do
          expect(products).to contain_exactly(product_1)
        end
      end

      context "for option values" do
        let(:option_value_ids) { [] }
        let(:params) do
          {
            filter: {
              option_value_ids: option_value_ids
            }
          }
        end

        context "filtering by one option" do
          let(:option_value_ids) { [option_value_1_1.id] }

          it "returns products with proper option values" do
            expect(products).to match_array([product_1, product_3])
          end
        end

        context "filtering by several options" do
          let(:option_value_ids) { [option_value_1_1.id, option_value_2_2.id] }

          it "returns products that have both options" do
            expect(products).to match_array([product_3])
          end
        end
      end
    end

    describe "filter by categories" do
      subject(:products) do
        described_class.new(
          scope: scope,
          params: params
        ).execute
      end

      let!(:scope) { Aypex::Product.all }
      let(:parent_category) { child_category.parent }
      let(:child_category) { create(:category) }

      context "one category is requested in params" do
        let(:params) { {store: store, filter: {categories: parent_category.id}} }

        shared_examples "returns distinct products associated both to self and descendants" do
          it { expect(products).to match_array [product, product_2] }
        end

        before do
          parent_category.products << product
          child_category.products << product_2
        end

        it_behaves_like "returns distinct products associated both to self and descendants"

        context "when product is already related to both categories" do
          before { parent_category.products << product_2 }

          it_behaves_like "returns distinct products associated both to self and descendants"
        end
      end

      context "multiple categories are requested" do
        let(:params) { {store: store, filter: {categories: "#{category.id},#{category_2.id}"}} }
        let(:category) { create(:category) }
        let(:category_2) { create(:category) }

        before do
          category.products << product
          category_2.products << product_2
        end

        it { expect(products).to match_array [product, product_2] }
      end

      context "multiple categories + 1 concat_categories are requested" do
        let(:params) { {store: store, filter: {categories: "#{category.id},#{category_2.id}", concat_categories: category_3.id.to_s}} }
        let(:category) { create(:category) }
        let(:category_2) { create(:category) }
        let(:category_3) { create(:category) }

        before do
          category.products << product
          category_2.products << product_2
          category_3.products << product_2
          category_3.products << product_3
        end

        it { expect(products).to match_array [product_2] }
      end

      context "only multiple concat_categories are requested" do
        let(:params) { {store: store, filter: {concat_categories: "#{category_2.id},#{category_3.id}"}} }
        let(:category) { create(:category) }
        let(:category_2) { create(:category) }
        let(:category_3) { create(:category) }

        before do
          category.products << product
          category_2.products << product_2
          category_3.products << product_2
          category_3.products << product_3
        end

        it { expect(products).to match_array [product_2] }
      end

      context "only one concat_categories is requested" do
        let(:params) { {store: store, filter: {concat_categories: category_3.id.to_s}} }
        let(:category) { create(:category) }
        let(:category_2) { create(:category) }
        let(:category_3) { create(:category) }

        before do
          category.products << product
          category_2.products << product_2
          category_3.products << product_2
          category_3.products << product_3
        end

        it { expect(products).to match_array [product_2, product_3] }
      end

      context "products scope is another store" do
        let!(:scope) { store.products }

        context "passed store has no categories" do
          let(:store) { create(:store) }
          let(:params) { {store: store, filter: {categories: parent_category.id}} }

          before do
            parent_category.products << product
          end

          it { expect(products).to be_empty }
        end
      end
    end

    describe "filter by prices" do
      subject(:products) do
        described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute
      end

      let(:params) { {filter: {price: price_param}} }

      context "for a price less than 20" do
        let(:price_param) { "0,20" }

        it { is_expected.to contain_exactly(product, product_3, in_stock_product, not_backorderable_product) }
      end

      context "for a price between 16 and 24" do
        let(:price_param) { "16,24" }

        it { is_expected.to contain_exactly(product_2, product_3, in_stock_product, not_backorderable_product) }
      end

      context "for a price more than 23" do
        let(:price_param) { "23,Infinity" }

        it do
          expect(subject).to contain_exactly(product_2)
        end
      end
    end

    describe "filter by properties" do
      subject(:products) do
        described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute
      end

      let(:params) do
        {filter: {properties: ActionController::Parameters.new(properties_param)}}
      end

      let(:brand) { create(:property, :brand) }
      let(:manufacturer) { create(:property, :manufacturer) }
      let(:material) { create(:property, :material) }

      let!(:product_1) do
        create(
          :product,
          product_properties: [
            create(:product_property, property: brand, value: "Alpha"),
            create(:product_property, property: manufacturer, value: "Wilson")
          ]
        )
      end

      let!(:product_2) do
        create(
          :product,
          product_properties: [
            create(:product_property, property: brand, value: "Beta"),
            create(:product_property, property: manufacturer, value: "Jerseys")
          ]
        )
      end

      let(:product_3) do
        create(
          :product,
          product_properties: [
            create(:product_property, property: brand, value: "Alpha")
          ]
        )
      end

      before do
        create(:product, product_properties: [create(:product_property, property: manufacturer, value: "Jerseys")])
        create(:product, product_properties: [create(:product_property, property: material, value: "100% Cotton")])
      end

      context "when filtering by one Property" do
        let(:properties_param) { {brand: "alpha,beta,gamma"} }

        it "finds Products matching any of Property values" do
          expect(products).to contain_exactly(product_1, product_2, product_3)
        end
      end

      context "when filtering by many Properties" do
        let(:properties_param) { {brand: "alpha,beta,gamma", manufacturer: "wilson,jerseys"} }

        it "finds Products matching any of Property values, but for all given Properties" do
          expect(products).to contain_exactly(product_1, product_2)
        end
      end
    end

    context "ordered" do
      context "default" do
        subject(:products) do
          described_class.new(
            scope: Aypex::Product.all,
            params: params
          ).execute
        end

        context "when not filtering by categories" do
          let(:params) { {sort_by: "default"} }

          it "returns products in default order" do
            expect(products.ids).to match_array Aypex::Product.available.ids
          end
        end

        context "when filtering by categories" do
          let(:params) do
            {store: store, sort_by: "default", filter: {categories: base_category.root.id}}
          end

          let(:base_category) { create(:base_category) }
          let(:child_category_1) { create(:category, base_category: base_category) }
          let(:child_category_2) { create(:category, base_category: base_category) }

          before do
            product.categories << child_category_1
            product_2.categories << child_category_1
            product_3.categories << child_category_2

            # swap products positions
            product.classifications.find_by(category: child_category_1).update(position: 3)
            product_3.classifications.find_by(category: child_category_2).update(position: 2)
            product_2.classifications.find_by(category: child_category_1).update(position: 1)
          end

          it "returns products ordered by associated category position" do
            expect(products).to eq [product_2, product_3, product]
          end
        end
      end

      it "returns products in newest-first order" do
        params = {
          sort_by: "newest-first"
        }

        product_ids = described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute.map(&:id)

        expect(product_ids).to eq Aypex::Product.available.order(make_active_at: :desc).map(&:id)
      end

      it "returns products in price-high-to-low order" do
        params = {
          sort_by: "price-high-to-low"
        }

        products = described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute.to_a

        expect(products).to match_array([product_2, product_3, product, in_stock_product, not_backorderable_product])
      end

      it "returns products in price-low-to-high order" do
        params = {
          sort_by: "price-low-to-high"
        }

        products = described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute

        expect(products).to match_array([product, product_3, product_2, in_stock_product, not_backorderable_product])
      end

      it "returns products in name-a-z order" do
        params = {
          sort_by: "name-a-z"
        }

        products = described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute

        expect(products).to match_array([product, product_2, product_3, in_stock_product, not_backorderable_product])
      end

      it "returns products in name-z-a order" do
        params = {
          sort_by: "name-z-a"
        }

        products = described_class.new(
          scope: Aypex::Product.all,
          params: params
        ).execute

        expect(products).to match_array([product_3, product_2, product, in_stock_product, not_backorderable_product])
      end
    end
  end
end
