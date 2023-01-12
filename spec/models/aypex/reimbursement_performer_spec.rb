require "spec_helper"

describe Aypex::ReimbursementPerformer do
  let(:reimbursement) { create(:reimbursement, return_items_count: 1) }
  let(:return_item) { reimbursement.return_items.first }
  let(:reimbursement_type) { double("ReimbursementType") }
  let(:reimbursement_type_hash) { {reimbursement_type => [return_item]} }
  let(:reimbursement_type_engine) { Aypex::Reimbursement::ReimbursementTypeEngine }

  before do
    allow_any_instance_of(reimbursement_type_engine).to receive(:calculate_reimbursement_types).and_return(reimbursement_type_hash)
  end

  describe ".simulate" do
    it "reimburses each calculated reimbursement types with the correct return items as a simulation" do
      expect(reimbursement_type).to receive(:reimburse).with(reimbursement, [return_item], true)
      Aypex::ReimbursementPerformer.simulate(reimbursement)
    end
  end

  describe ".perform" do
    it "reimburses each calculated reimbursement types with the correct return items as a performance" do
      expect(reimbursement_type).to receive(:reimburse).with(reimbursement, [return_item], false)
      Aypex::ReimbursementPerformer.perform(reimbursement)
    end
  end
end
