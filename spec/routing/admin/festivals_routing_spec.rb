require "spec_helper"

describe Admin::FestivalsController do
  describe "routing" do
    it "doesn't route to #index" do
      get("/admin/festivals").should_not be_routable
    end

    it "routes to #show" do
      get("/admin/festivals/1").should route_to("admin/festivals#show", :id => "1")
    end

    it "routes to #new" do
      get("/admin/festivals/new").should route_to("admin/festivals#new")
    end

    it "routes to #create" do
      post("/admin/festivals").should route_to("admin/festivals#create")
    end

    it "routes to #edit" do
      get("/admin/festivals/1/edit").should route_to("admin/festivals#edit", :id => "1")
    end

    it "routes to #update" do
      put("/admin/festivals/1").should route_to("admin/festivals#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/festivals/1").should route_to("admin/festivals#destroy", :id => "1")
    end
  end
end
