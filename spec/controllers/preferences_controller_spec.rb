require 'rails_helper'

describe PreferencesController, type: :controller do
  let(:user) { create(:confirmed_user) }

  describe "PUT update" do
    let(:preference) { 'hide_instructions' }
    let(:value) { "true" }
    subject { put :update, params: { id: preference, value: value, format: :js } }

    it "requires an authenticated user" do
      subject
      response.response_code.should == 401
    end

    describe "with a signed-in user" do
      login_user

      describe "with valid params" do
        it 'updates the signed-in user' do
          @signed_in_user.send(preference).should be false
          subject
          @signed_in_user.reload.send(preference).should be true
        end

        it "responds with :ok status" do
          subject
          response.response_code.should == 200
        end
      end

      describe "with an invalid preference" do
        let!(:preference) { 'bogus' }

        it "responds with :unprocessible_entity status" do
          subject
          response.response_code.should == 422
        end
      end
    end
  end
end
