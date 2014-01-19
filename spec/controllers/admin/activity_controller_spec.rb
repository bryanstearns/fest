require 'spec_helper'

describe Admin::ActivityController do
  login_admin
  def valid_attributes
    attributes_for(:activity)
  end

  describe "GET index" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let!(:activity) { [ create(:activity, user: user),
                          create(:activity, user: another_user) ] }
    context "with a user id" do
      it "assigns that user's activity as @activity" do
        get :index, { user_id: user.id }
        assigns(:activity).should eq([activity.first])
      end
    end
    context "without a user id" do
      it "assigns all activity as @activities" do
        get :index, {}
        assigns(:activity).should eq(activity)
      end
    end
  end
end
