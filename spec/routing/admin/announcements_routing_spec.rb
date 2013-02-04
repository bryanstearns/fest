require "spec_helper"

describe Admin::AnnouncementsController do
  describe "routing" do
    it "routes to #new" do
      get("/admin/announcements/new").should route_to("admin/announcements#new")
    end

    it "routes to #edit" do
      get("/admin/announcements/1/edit").should route_to("admin/announcements#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/announcements").should route_to("admin/announcements#create")
    end

    it "routes to #update" do
      put("/admin/announcements/1").should route_to("admin/announcements#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/announcements/1").should route_to("admin/announcements#destroy", :id => "1")
    end
  end
end
