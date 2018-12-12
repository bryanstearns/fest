require 'rails_helper'

describe Admin::AnnouncementsController, type: :controller do
  login_admin

  # This should return the minimal set of attributes required to create a valid
  # Announcement. As you add validations to Announcement, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    attributes_for(:announcement)
  end

  describe "GET new" do
    it "assigns a new announcement as @announcement" do
      get :new, params: {}
      expect(assigns(:announcement)).to be_a_new(Announcement)
      expect(assigns(:announcement).published_at).to be_within(5.seconds).of(Time.current)
    end
  end

  describe "GET edit" do
    it "assigns the requested announcement as @announcement" do
      announcement = Announcement.create! valid_attributes
      get :edit, params: {:id => announcement.to_param}
      assigns(:announcement).should eq(announcement)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Announcement" do
        expect {
          post :create, params: {:announcement => valid_attributes}
        }.to change(Announcement, :count).by(1)
      end

      it "assigns a newly created announcement as @announcement" do
        post :create, params: {:announcement => valid_attributes}
        assigns(:announcement).should be_a(Announcement)
        assigns(:announcement).should be_persisted
      end

      it "redirects to the announcements page" do
        post :create, params: {:announcement => valid_attributes}
        response.should redirect_to(announcements_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved announcement as @announcement" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Announcement).to receive(:save).and_return(false)
        allow_any_instance_of(Announcement).to receive(:errors).and_return(some: ['errors'])
        post :create, params: {:announcement => { "subject" => "" }}
        assigns(:announcement).should be_a_new(Announcement)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Announcement).to receive(:save).and_return(false)
        allow_any_instance_of(Announcement).to receive(:errors).and_return(some: ['errors'])
        post :create, params: {:announcement => { "subject" => "" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested announcement" do
        announcement = Announcement.create! valid_attributes
        # Assuming there are no other announcements in the database, this
        # specifies that the Announcement created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        allow_any_instance_of(Announcement).
          to receive(:update_attributes).
          with(PermittedParams.new("subject" => "MyString"))
        put :update, params: {:id => announcement.to_param,
                              :announcement => { "subject" => "MyString" }}
      end

      it "assigns the requested announcement as @announcement" do
        announcement = Announcement.create! valid_attributes
        put :update, params: {:id => announcement.to_param, :announcement => valid_attributes}
        assigns(:announcement).should eq(announcement)
      end

      it "redirects to the announcements page" do
        announcement = Announcement.create! valid_attributes
        put :update, params: {:id => announcement.to_param, :announcement => valid_attributes}
        response.should redirect_to(announcements_path)
      end
    end

    describe "with invalid params" do
      it "assigns the announcement as @announcement" do
        announcement = Announcement.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Announcement).to receive(:save).and_return(false)
        allow_any_instance_of(Announcement).to receive(:errors).and_return(some: ['errors'])
        put :update, params: {:id => announcement.to_param, :announcement => { "subject" => "" }}
        assigns(:announcement).should eq(announcement)
      end

      it "re-renders the 'edit' template" do
        announcement = Announcement.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Announcement).to receive(:save).and_return(false)
        allow_any_instance_of(Announcement).to receive(:errors).and_return(some: ['errors'])
        put :update, params: {:id => announcement.to_param, :announcement => { "subject" => "" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested announcement" do
      announcement = Announcement.create! valid_attributes
      expect {
        delete :destroy, params: {:id => announcement.to_param}
      }.to change(Announcement, :count).by(-1)
    end

    it "redirects to the announcements list" do
      announcement = Announcement.create! valid_attributes
      delete :destroy, params: {:id => announcement.to_param}
      response.should redirect_to(announcements_url)
    end
  end

end
