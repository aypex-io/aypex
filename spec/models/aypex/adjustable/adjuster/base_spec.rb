require "spec_helper"

describe Aypex::Adjustable::Adjuster::Base do
  let(:line_item) { create(:line_item) }
  let(:subject) { Aypex::Adjustable::Adjuster::Base }

  it "raises missing update method" do
    expect { subject.adjust(line_item, {}) }.to raise_error(NotImplementedError)
  end
end
