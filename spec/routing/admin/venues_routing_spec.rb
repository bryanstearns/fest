require "spec_helper"

describe Admin::VenuesController, type: :routing do
  describe "routing" do

    it "doesn't route to #index" do
      get("/admin/venues").should_not be_routable
    end

    it "doesn't route to #show" do
      get("/admin/venues/1").should_not be_routable
    end

    it "routes to #new with location" do
      get("/admin/locations/1/venues/new").should route_to("admin/venues#new", :location_id => "1")
    end

    it "routes to #create with location" do
      post("/admin/locations/1/venues").should route_to("admin/venues#create", :location_id => "1")
    end

    it "routes to #edit" do
      get("/admin/venues/1/edit").should route_to("admin/venues#edit", :id => "1")
    end

    it "routes to #update" do
      put("/admin/venues/1").should route_to("admin/venues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/venues/1").should route_to("admin/venues#destroy", :id => "1")
    end

  end
end
