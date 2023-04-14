require "spec_helper"

module Aypex
  describe Account::Create do
    subject { described_class }
    let(:store) { create(:store) }
    let(:result) { subject.call(user_params: user_params) }
    let(:value) { result.value }

    describe "#call" do
      context "with valid params" do
        let(:user_params) do
          {
            email: "new_email@email.com",
            password: "password123",
            password_confirmation: "password123",
            store_id: store.id
          }
        end

        it "creates new user" do
          expect { result }.to change(Aypex::Config.user_class, :count)
        end

        it "creates user with given params" do
          expect(value).to have_attributes(user_params)
        end

        it "result is successful" do
          expect(result).to be_success
        end
      end

      # did not add unhappy path because validations are included in aypex_auth_devise gem
    end
  end
end
