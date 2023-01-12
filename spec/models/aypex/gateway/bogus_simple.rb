require "spec_helper"

describe Aypex::Gateway::BogusSimple do
  subject { Aypex::Gateway::BogusSimple.new }

  # regression test for #3824
  describe "#capture" do
    it "returns success with the right response code" do
      response = subject.capture(123, "12345", {})
      expect(response.message).to include("success")
    end

    it "returns failure with the wrong response code" do
      response = subject.capture(123, "wrong", {})
      expect(response.message).to include("failure")
    end
  end
end
