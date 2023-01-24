require "spec_helper"
require "testing_support/url_helpers"

class FakesController < ApplicationController
  include Aypex::ControllerHelpers::Auth
  def index
    render plain: "index"
  end
end

describe Aypex::ControllerHelpers::Auth, type: :controller do
  controller(FakesController) {}
  include Aypex::TestingSupport::UrlHelpers

  describe "#current_ability" do
    it "returns Aypex::Ability instance" do
      expect(controller.current_ability.class).to eq Aypex::Ability
    end
  end

  describe "#redirect_back_or_default" do
    controller(FakesController) do
      def index
        redirect_back_or_default("/")
      end
    end

    it "redirects to session url" do
      session[:aypex_user_return_to] = "/redirect"
      get :index
      expect(response).to redirect_to("/redirect")
    end

    it "redirects to HTTP_REFERER" do
      request.env["HTTP_REFERER"] = "/dummy_redirect"
      get :index
      expect(response).to redirect_to("/dummy_redirect")
    end

    it "redirects to default page" do
      get :index
      expect(response).to redirect_to("/")
    end
  end

  describe "#set_token" do
    controller(FakesController) do
      def index
        set_token
        render plain: "index"
      end
    end

    it "sends cookie header" do
      get :index
      expect(response.cookies["token"]).not_to be_nil
    end

    it "sets HttpOnly flag" do
      get :index
      expect(response["Set-Cookie"]).to include("HttpOnly")
    end
  end

  describe "#store_location" do
    it "sets session return url" do
      allow(controller).to receive_messages(request: double(fullpath: "/redirect"))
      controller.store_location
      expect(session[:aypex_user_return_to]).to eq "/redirect"
    end
  end

  describe "#try_aypex_current_user" do
    it "calls aypex_current_user when define aypex_current_user method" do
      expect(controller).to receive(:aypex_current_user)
      controller.try_aypex_current_user
    end

    it "calls current_aypex_user when define current_aypex_user method" do
      expect(controller).to receive(:current_aypex_user)
      controller.try_aypex_current_user
    end

    it "returns nil" do
      expect(controller.try_aypex_current_user).to be_nil
    end
  end
end
