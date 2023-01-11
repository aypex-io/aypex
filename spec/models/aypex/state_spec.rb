require "spec_helper"

describe Aypex::State, type: :model do
  it "can find a state by name or abbr" do
    state = create(:state, name: "California", abbr: "CA")
    expect(Aypex::State.find_all_by_name_or_abbr("California")).to include(state)
    expect(Aypex::State.find_all_by_name_or_abbr("CA")).to include(state)
  end

  it "can find all states group by country id" do
    state = create(:state)
    expect(Aypex::State.states_group_by_country_id).to eq(state.country_id.to_s => [[state.id, state.name]])
  end

  describe "whitelisted_ransackable_attributes" do
    it { expect(Aypex::State.whitelisted_ransackable_attributes).to eq(%w[abbr country_id name]) }
  end
end
