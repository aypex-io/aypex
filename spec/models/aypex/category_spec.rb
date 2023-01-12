require "spec_helper"

describe Aypex::Category, type: :model do
  let(:base_category) { create(:base_category) }
  let(:category) { build(:category, name: "Ruby on Rails", parent: nil) }

  it_behaves_like "metadata"

  describe "#to_param" do
    subject { super().to_param }

    it { is_expected.to eql category.permalink }
  end

  context "validations" do
    describe "#check_for_root" do
      let(:valid_category) { build(:category, name: "Valid Rails", parent_id: 1, base_category: base_category) }

      it "does not validate the category" do
        expect(category.valid?).to eq false
      end

      it "validates the category" do
        expect(valid_category.valid?).to eq true
      end
    end

    describe "#parent_belongs_to_same_base_category" do
      let(:valid_parent) { create(:category, name: "Valid Parent", base_category: base_category) }
      let(:invalid_parent) { create(:category, name: "Invalid Parent", base_category: create(:base_category)) }

      it "does not validate the category" do
        expect(build(:category, base_category: base_category, parent: invalid_parent).valid?).to eq false
      end

      it "validates the category" do
        expect(build(:category, base_category: base_category, parent: valid_parent).valid?).to eq true
      end
    end
  end

  context "set_permalink" do
    it "sets permalink correctly when no parent present" do
      category.set_permalink
      expect(category.permalink).to eql "ruby-on-rails"
    end

    it "supports Chinese characters" do
      category.name = "你好"
      category.set_permalink
      expect(category.permalink).to eql "ni-hao"
    end

    it "stores old slugs in FriendlyIds history" do
      # Stub out the unrelated methods that cannot handle a save without an id
      allow(subject).to receive(:set_depth!)
      expect(subject).to receive(:create_slug)
      subject.permalink = "custom-slug"
      subject.run_callbacks :save
    end

    context "with parent category" do
      let(:parent) { FactoryBot.build(:category, permalink: "brands") }

      before { allow(category).to receive_messages parent: parent }

      it "sets permalink correctly when category has parent" do
        category.set_permalink
        expect(category.permalink).to eql "brands/ruby-on-rails"
      end

      it "sets permalink correctly with existing permalink present" do
        category.permalink = "b/rubyonrails"
        category.set_permalink
        expect(category.permalink).to eql "brands/rubyonrails"
      end

      it "supports Chinese characters" do
        category.name = "我"
        category.set_permalink
        expect(category.permalink).to eql "brands/wo"
      end

      # Regression test for #3390
      context "setting a new node sibling position via :child_index=" do
        let(:idx) { rand(0..100) }

        before { allow(parent).to receive(:move_to_child_with_index) }

        context "category is not new" do
          before { allow(category).to receive(:new_record?).and_return(false) }

          it "passes the desired index move_to_child_with_index of :parent" do
            expect(category).to receive(:move_to_child_with_index).with(parent, idx)

            category.child_index = idx
          end
        end
      end
    end
  end

  # Regression test for #2620
  context "creating a child node using first_or_create" do
    let!(:base_category) { create(:base_category) }

    it "does not error out" do
      expect { base_category.root.children.unscoped.where(name: "Some name", parent_id: base_category.categories.first.id).first_or_create }.not_to raise_error
    end
  end

  context "ransackable_associations" do
    it { expect(described_class.whitelisted_ransackable_associations).to include("base_category") }
  end

  describe "#cached_self_and_descendants_ids" do
    it { expect(category.cached_self_and_descendants_ids).to eq(category.self_and_descendants.ids) }
  end

  describe "#copy_base_category_from_parent" do
    let!(:parent) { create(:category, base_category: base_category) }
    let(:category) { build(:category, parent: parent, base_category: nil) }

    it { expect(category.valid?).to eq(true) }
    it { expect { category.save }.to change(category, :base_category).to(base_category) }
  end

  describe "#sync_base_category_name" do
    let!(:base_category) { create(:base_category, name: "Soft Goods") }
    let!(:category) { create(:category, base_category: base_category, name: "Socks") }

    context "when none root category name is updated" do
      it "does not update the base_category name" do
        category.update(name: "Shoes")
        category.save!
        base_category.reload

        expect(base_category.name).not_to eql category.name
        expect(base_category.name).to eql "Soft Goods"
      end
    end

    context "when root category name is updated" do
      it "updates the base_category name" do
        root_category = described_class.find_by(name: "Soft Goods")

        root_category.update(name: "Hard Goods")
        root_category.save!
        base_category.reload

        expect(base_category.name).not_to eql "Soft Goods"
        expect(base_category.name).to eql root_category.name
      end
    end

    context "when root category name is updated with special characters" do
      it "updates the base_category name" do
        root_category = described_class.find_by(name: "Soft Goods")

        root_category.update(name: "spÉcial Numérique ƒ ˙ ¨ πø∆©")
        root_category.save!
        base_category.reload

        expect(base_category.name).not_to eql "Soft Goods"
        expect(base_category.name).to eql root_category.name
      end
    end

    context "when root category attribute other than name is updated" do
      it "does not update the base_category" do
        root_category = described_class.find_by(name: "Soft Goods")
        base_category_updated_at = base_category.updated_at.to_s

        expect {
          root_category.update(permalink: "something-else")
          root_category.save!
          root_category.reload
          base_category.reload
        }.not_to change { base_category.updated_at.to_s }.from(base_category_updated_at)

        expect(root_category.permalink).to eql "something-else"
      end
    end
  end
end
