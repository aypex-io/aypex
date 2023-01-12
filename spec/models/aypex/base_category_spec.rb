require "spec_helper"

describe Aypex::BaseCategory do
  it_behaves_like "metadata"

  describe "#destroy" do
    before do
      @base_category = create(:base_category)
      @root_category = @base_category.root
      @child_category = create(:category, base_category_id: @base_category.id, parent: @root_category)
    end

    it "destroys all associated categories" do
      @base_category.destroy
      expect { Aypex::Category.find(@root_category.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Aypex::Category.find(@child_category.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#set_root_category_name" do
    before do
      @base_category = create(:base_category, name: "Clothing")
      @base_category.reload
    end

    context "when BaseCategory is created" do
      it "sets the root BaseCategory name to match" do
        expect(@base_category.root.name).to eq("Clothing")
      end
    end

    context "when BaseCategory name is updated" do
      it "changes the root Category name to match" do
        @base_category.update(name: "Soft Goods")
        @base_category.save!
        @base_category.reload

        expect(@base_category.root.name).to eq("Soft Goods")
      end
    end

    context "when BaseCategory position is updated" do
      it "does not change the root Category name" do
        @base_category.update(position: 2)
        @base_category.save!
        @base_category.reload

        expect(@base_category.root.name).to eq("Clothing")
        expect(@base_category.position).to eq(2)
      end
    end
  end
end
