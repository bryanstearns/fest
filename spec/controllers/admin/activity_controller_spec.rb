require 'rails_helper'

describe Admin::ActivityController, type: :controller do
  login_admin
  def valid_attributes
    attributes_for(:activity)
  end

  describe "GET index" do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let!(:activity) { [ create(:activity, user: user),
                        create(:activity, user: user),
                        create(:activity, user: another_user) ] }
    context "with a user id" do
      it "assigns that user's activity as @activity newest first" do
        get :index, { user_id: user.id }
        assigns(:activity).should eq(activity[0..1].reverse)
      end
    end
    context "without a user id" do
      it "assigns all activity as @activities newest first" do
        get :index, {}
        assigns(:activity).should eq(activity.reverse)
      end
    end
  end
end
