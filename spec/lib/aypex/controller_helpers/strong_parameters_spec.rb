require "spec_helper"

class FakesController < ApplicationController
  include Aypex::ControllerHelpers::StrongParameters
end

describe Aypex::ControllerHelpers::StrongParameters, type: :controller do
  controller(FakesController) {}

  describe "#permitted_attributes" do
    it "returns Aypex::PermittedAttributes module" do
      expect(controller.permitted_attributes).to eq Aypex::PermittedAttributes
    end
  end

  describe "#permitted_payment_attributes" do
    it "returns Array class" do
      expect(controller.permitted_payment_attributes.class).to eq Array
    end
  end

  describe "#permitted_checkout_attributes" do
    it "returns Array class" do
      expect(controller.permitted_checkout_attributes.class).to eq Array
    end
  end

  describe "#permitted_order_attributes" do
    it "returns Array class" do
      expect(controller.permitted_order_attributes.class).to eq Array
    end
  end

  describe "#permitted_product_attributes" do
    it "returns Array class" do
      expect(controller.permitted_product_attributes.class).to eq Array
    end
  end
end
