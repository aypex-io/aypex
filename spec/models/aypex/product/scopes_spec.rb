require "spec_helper"

describe "Product scopes" do
  let(:store) { create(:store) }
  let!(:product) { create(:product, stores: [store]) }

  describe "#available" do
    context "when discontinued" do
      let!(:discontinued_product) { create(:product, status: "archived", stores: [store]) }

      it { expect(Aypex::Product.available).not_to include(discontinued_product) }
    end

    context "when not discontinued" do
      let!(:product_2) { create(:product, discontinue_on: Time.current + 1.day, stores: [store]) }

      it { expect(Aypex::Product.available).to include(product_2) }
    end

    context "when available" do
      let!(:product_2) { create(:product, status: "active", stores: [store]) }

      it { expect(Aypex::Product.available).to include(product_2) }
    end

    context "when not available" do
      let!(:unavailable_product) { create(:product, status: "draft", stores: [store]) }

      it { expect(Aypex::Product.available).not_to include(unavailable_product) }
    end

    context "different currency" do
      let!(:price_eur) { create(:price, variant: product.master, currency: "EUR") }
      let!(:product_2) { create(:product, stores: [store]) }

      it { expect(Aypex::Product.available(nil, "EUR")).to include(product) }
      it { expect(Aypex::Product.available(nil, "EUR")).not_to include(product_2) }
    end
  end

  describe ".for_filters" do
    subject { Aypex::Product.method(:for_filters) }

    let(:category_1) { create(:category) }
    let(:category_2) { create(:category) }

    let!(:product_1) { create(:product, currency: "GBP", categories: [category_1], stores: [store]) }
    let!(:product_2) { create(:product, currency: "GBP", categories: [category_2], stores: [store]) }

    before do
      create(:product, currency: "USD", categories: [create(:category)], stores: [store])
    end

    context "when giving a category" do
      it { expect(subject.call("GBP", category: category_1)).to contain_exactly(product_1) }
    end

    context "when giving a currency with no products" do
      it { expect(subject.call("PLN")).to be_empty }
    end
  end

  context "A product assigned to parent and child categories" do
    before do
      @base_category = create(:base_category)
      @root_category = @base_category.root

      @parent_category = create(:category, name: "Parent", base_category_id: @base_category.id, parent: @root_category)
      @child_category = create(:category, name: "Child 1", base_category_id: @base_category.id, parent: @parent_category)
      @parent_category.reload # Need to reload for descendents to show up

      product.categories << @parent_category
      product.categories << @child_category
    end

    it "calling Product.in_category returns products in child categories" do
      product.categories -= [@child_category]
      expect(product.categories.count).to eq(1)

      expect(Aypex::Product.in_category(@parent_category)).to include(product)
    end

    it "calling Product.in_category should not return duplicate records" do
      expect(Aypex::Product.in_category(@parent_category).to_a.size).to eq(1)
    end

    context "orders products based on their ordering within the classifications" do
      let(:other_category) { create(:category, products: [product]) }
      let!(:product_2) { create(:product, categories: [@child_category, other_category], stores: [store]) }

      it "by initial ordering" do
        expect(Aypex::Product.in_category(@child_category)).to eq([product, product_2])
        expect(Aypex::Product.in_category(other_category)).to eq([product, product_2])
      end

      it "after ordering changed" do
        [@child_category, other_category].each do |category|
          Aypex::Classification.find_by(category: category, product: product).insert_at(2)
          expect(Aypex::Product.in_category(category)).to eq([product_2, product])
        end
      end
    end
  end

  context "property scopes" do
    let(:name) { property.name }
    let(:value) { "Alpha" }

    let(:product_property) { create(:product_property, property: property, value: value) }
    let(:property) { create(:property, :brand) }

    before do
      product.product_properties << product_property
    end

    context "with_property" do
      subject(:with_property) { Aypex::Product.method(:with_property) }

      it "finds by a property's name" do
        expect(with_property.call(name).count).to eq(1)
      end

      it "doesn't find any properties with an unknown name" do
        expect(with_property.call("fake").count).to eq(0)
      end

      it "finds by a property" do
        expect(with_property.call(property).count).to eq(1)
      end

      it "finds by an id" do
        expect(with_property.call(property.id).count).to eq(1)
      end

      it "cannot find a property with an unknown id" do
        expect(with_property.call(0).count).to eq(0)
      end
    end

    context "with_property_value" do
      subject(:with_property_value) { Aypex::Product.method(:with_property_value) }

      it "finds by a property's name" do
        expect(with_property_value.call(name, value).count).to eq(1)
      end

      it "cannot find by an unknown property's name" do
        expect(with_property_value.call("fake", value).count).to eq(0)
      end

      it "cannot find with a name by an incorrect value" do
        expect(with_property_value.call(name, "fake").count).to eq(0)
      end

      it "finds by a property" do
        expect(with_property_value.call(property, value).count).to eq(1)
      end

      it "cannot find with a property by an incorrect value" do
        expect(with_property_value.call(property, "fake").count).to eq(0)
      end

      it "finds by an id with a value" do
        expect(with_property_value.call(property.id, value).count).to eq(1)
      end

      it "cannot find with an invalid id" do
        expect(with_property_value.call(0, value).count).to eq(0)
      end

      it "cannot find with an invalid value" do
        expect(with_property_value.call(property.id, "fake").count).to eq(0)
      end
    end

    context "with_property_values" do
      subject(:with_property_values) { Aypex::Product.method(:with_property_values) }

      let!(:product_2) { create(:product, product_properties: [product_2_property], stores: [store]) }
      let(:product_2_property) { create(:product_property, property: property, value: value_2) }
      let(:value_2) { "Beta 10%" }

      before do
        create(:product, product_properties: [create(:product_property, property: property, value: "20% Gamma")], stores: [store])
      end

      it "finds by property values" do
        expect(with_property_values.call(name, [value, value_2, "non_existent"])).to contain_exactly(
          product, product_2
        )
      end

      it "cannot find with an invalid property name" do
        expect(with_property_values.call("fake", [value, value_2])).to be_empty
      end

      it "cannot find with invalid property values" do
        expect(with_property_values.call(name, ["fake"])).to be_empty
      end
    end
  end

  describe "#add_simple_scopes" do
    let(:simple_scopes) { [:ascend_by_updated_at, :descend_by_name] }

    before do
      Aypex::Product.add_simple_scopes(simple_scopes)
    end

    context "define scope" do
      context "ascend_by_updated_at" do
        context "on class" do
          it { expect(Aypex::Product.ascend_by_updated_at.to_sql).to eq Aypex::Product.order(Arel.sql("#{Aypex::Product.quoted_table_name}.updated_at ASC")).to_sql }
        end

        context "on ActiveRecord::Relation" do
          it { expect(Aypex::Product.limit(2).ascend_by_updated_at.to_sql).to eq Aypex::Product.limit(2).order(Arel.sql("#{Aypex::Product.quoted_table_name}.updated_at ASC")).to_sql }
          it { expect(Aypex::Product.limit(2).ascend_by_updated_at.to_sql).to eq Aypex::Product.ascend_by_updated_at.limit(2).to_sql }
        end
      end

      context "descend_by_name" do
        context "on class" do
          it { expect(Aypex::Product.descend_by_name.to_sql).to eq Aypex::Product.order(Arel.sql("#{Aypex::Product.quoted_table_name}.name DESC")).to_sql }
        end

        context "on ActiveRecord::Relation" do
          it { expect(Aypex::Product.limit(2).descend_by_name.to_sql).to eq Aypex::Product.limit(2).order(Arel.sql("#{Aypex::Product.quoted_table_name}.name DESC")).to_sql }
          it { expect(Aypex::Product.limit(2).descend_by_name.to_sql).to eq Aypex::Product.descend_by_name.limit(2).to_sql }
        end
      end
    end
  end

  describe "#search_by_name" do
    let!(:first_product) { create(:product, name: "First product", stores: [store]) }
    let!(:second_product) { create(:product, name: "Second product", stores: [store]) }
    let!(:third_product) { create(:product, name: "Other second product", stores: [store]) }

    it "shows product whose name contains phrase" do
      result = Aypex::Product.search_by_name("First").to_a
      expect(result).to include(first_product)
      expect(result.count).to eq(1)
    end

    it "shows multiple products whose names contain phrase" do
      result = Aypex::Product.search_by_name("product").to_a
      expect(result).to include(product, first_product, second_product, third_product)
      expect(result.count).to eq(4)
    end

    it "is case insensitive for search phrases" do
      result = Aypex::Product.search_by_name("Second").to_a
      expect(result).to include(second_product, third_product)
      expect(result.count).to eq(2)
    end
  end

  describe "#ascend_by_categories_min_position" do
    subject(:ordered_products) { Aypex::Product.ascend_by_categories_min_position(categories) }

    let(:categories) { [parent_category, child_category_1, child_category_2, child_category_1_1, child_category_2_1] }

    let(:parent_category) { create(:category) }

    let(:child_category_1) { create(:category, parent: parent_category, base_category: parent_category.base_category) }
    let(:child_category_1_1) { create(:category, parent: child_category_1, base_category: child_category_1.base_category) }

    let(:child_category_2) { create(:category, parent: parent_category, base_category: parent_category.base_category) }
    let(:child_category_2_1) { create(:category, parent: child_category_2, base_category: child_category_2.base_category) }

    let!(:product_1) { create(:product, stores: [store]) }
    let!(:classification_1_1) { create(:classification, position: 5, product: product_1, category: parent_category) }
    let!(:classification_1_2) { create(:classification, position: 4, product: product_1, category: child_category_1_1) }

    let!(:product_2) { create(:product, stores: [store]) }
    let!(:classification_2_1) { create(:classification, position: 1, product: product_2, category: parent_category) }
    let!(:classification_2_2) { create(:classification, position: 2, product: product_2, category: child_category_2_1) }

    let!(:product_3) { create(:product, stores: [store]) }
    let!(:classification_3_1) { create(:classification, position: 3, product: product_3, category: child_category_1) }
    let!(:classification_3_2) { create(:classification, position: 4, product: product_3, category: child_category_2_1) }

    let!(:product_4) { create(:product, stores: [store]) }
    let!(:classification_4_1) { create(:classification, position: 2, product: product_4, category: child_category_2) }

    let!(:product_5) { create(:product, stores: [store]) }
    let!(:classification_5_1) { create(:classification, position: 1, product: product_5, category: child_category_1_1) }

    let!(:product_6) { create(:product, stores: [store]) }
    let!(:classification_6_1) { create(:classification, position: 6, product: product_6, category: child_category_2) }
    let!(:classification_6_2) { create(:classification, position: 3, product: product_6, category: child_category_1) }

    before do
      create_list(:product, 3, categories: [create(:category)], stores: [store])
    end

    it "orders products by ascending categories minimum position" do
      expect(ordered_products).to eq(
        [
          product_2, product_5, # position: 1
          product_4,            # position: 2
          product_6, product_3, # position: 3
          product_1             # position: 4
        ]
      )
    end
  end

  describe "#for_store" do
    subject(:products_by_store) { Aypex::Product.for_store(store) }

    before do
      create_list(:product, 3, stores: [create(:store)])
    end

    it "returns products assigned to a store" do
      expect(products_by_store).to contain_exactly(product)
    end
  end

  # Regression test for SD-1439 ambiguous column name: count_on_hand
  describe "#in_stock.in_stock_or_backorderable" do
    it do
      expect { Aypex::Product.in_stock.in_stock_or_backorderable.count }.not_to raise_error
    end
  end

  context "options scopes" do
    let(:option_type) { create(:option_type) }
    let(:option_value) { create(:option_value, option_type: option_type) }
    let!(:product) { create(:product, option_types: [option_type]) }
    let!(:variant) { create(:variant, product: product, option_values: [option_value]) }

    describe ".with_option" do
      subject(:with_option) { Aypex::Product.method(:with_option) }

      it "finds by a option type's name" do
        expect(with_option.call(option_type.name).count).to eq(1)
      end

      it "doesn't find any option types with an unknown name" do
        expect(with_option.call("fake").count).to eq(0)
      end

      it "finds by a option type" do
        expect(with_option.call(option_type).count).to eq(1)
      end

      it "finds by an id" do
        expect(with_option.call(option_type.id).count).to eq(1)
      end

      it "cannot find an option type with an unknown id" do
        expect(with_option.call(0).count).to eq(0)
      end
    end

    describe ".with_option_value" do
      subject(:with_option) { Aypex::Product.method(:with_option_value) }

      it "finds by a option type's name" do
        expect(with_option.call(option_type.name, option_value.name).count).to eq({product.id => 1})
      end

      it "doesn't find any option types with an unknown name" do
        expect(with_option.call("fake", "fake").count).to eq({})
      end

      it "finds by a option type" do
        expect(with_option.call(option_type, option_value.name).count).to eq({product.id => 1})
      end

      it "finds by an id" do
        expect(with_option.call(option_type.id, option_value.name).count).to eq({product.id => 1})
      end

      it "cannot find an option type with an unknown id" do
        expect(with_option.call(0, "fake").count).to eq({})
      end

      it "can return product ids" do
        expect(with_option.call(option_type, option_value.name).ids).to match_array([product.id])
      end
    end
  end
end
