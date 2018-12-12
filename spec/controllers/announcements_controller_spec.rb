require 'rails_helper'

describe AnnouncementsController, type: :controller do
  def valid_attributes
    attributes_for(:announcement)
  end

  describe "GET index" do
    context "when logged in as an admin" do
      login_admin
      it "assigns all announcements as @announcements" do
        announcement = create(:announcement) # unpublished!
        get :index, params: {}
        assigns(:announcements).should eq([announcement])
      end
    end
    context "when not logged in as an admin" do
      it "assigns published announcements as @announcements" do
        unpublished_announcement = create(:announcement)
        published_announcement = create(:announcement, :published)
        get :index, params: {}
        assigns(:announcements).should eq([published_announcement])
      end
    end
  end

  describe "GET show" do
    context "when logged in as an admin" do
      login_admin
      it "assigns the requested announcement as @announcement" do
        announcement = create(:announcement, :published)
        get :show, params: {:id => announcement.to_param}
        assigns(:announcement).should eq(announcement)
      end
    end
    context "when not logged in as an admin" do
      it "doesn't find unpublished announcements" do
        announcement = create(:announcement)
        expect {
          get :show, params: {:id => announcement.to_param}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST clear" do
    login_user
    it "updates the user's last-seen date" do
      post :clear
      @signed_in_user.reload.welcomed_at.should be > 5.minutes.ago
    end
    it "redirects to the announcements list" do
      post :clear
      response.should redirect_to(announcements_path)
    end
  end
end
