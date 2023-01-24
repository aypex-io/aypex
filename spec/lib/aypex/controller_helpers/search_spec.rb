require "spec_helper"

class FakesController < ApplicationController
  include Aypex::ControllerHelpers::Search
end

describe Aypex::ControllerHelpers::Search, type: :controller do
  controller(FakesController) {}

  describe "#build_searcher" do
    it "returns Aypex::Search::Base instance" do
      allow(controller).to receive_messages(try_aypex_current_user: create(:user),
        current_currency: "USD", current_store: Aypex::Store.default)
      expect(controller.build_searcher({}).class).to eq Aypex::Search::Base
    end
  end
end
