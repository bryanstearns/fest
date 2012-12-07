require 'spec_helper'

describe ApplicationController do
  describe 'requiring an admin' do
    controller do
      before_filter :authenticate_admin!
      def index; redirect_to '/' end
    end

    subject { get :index }

    describe "when logged in as an admin" do
      login_admin
      it "should not raise" do
        subject
      end
    end

    describe "when logged in as a non-admin" do
      login_user
      it "should raise" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "when not logged in" do
      logged_out
      it "should redirect to the sign-in page" do
        subject.should redirect_to(new_user_session_path)
      end
    end
  end
end
