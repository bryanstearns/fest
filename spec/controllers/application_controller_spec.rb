require 'rails_helper'

describe ApplicationController, type: :controller do
  describe 'requiring an admin' do
    controller do
      before_action :authenticate_admin!
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

  describe 'checking festival access' do
    let(:festival) { build(:festival, published: is_published) }
    before(:each) { allow(Festival).to receive(:find).and_return(festival) }

    controller do
      def index
        @festival = Festival.find(nil)
        check_festival_access
        redirect_to '/'
      end
    end

    describe 'on a published festival' do
      let(:is_published) { true }
      it 'should return quietly' do
        get :index
      end
    end

    describe 'on an unpublished festival' do
      let(:is_published) { false }
      it 'should raise' do
        expect { get :index }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
