require "spec_helper"

describe VenuesController do
  describe "routing" do

    it "doesn't route to #index" do
      get("/venues").should_not be_routable
    end

    it "routes to #new with location" do
      get("/locations/1/venues/new").should route_to("venues#new", :location_id => "1")
    end

    it "doesn't route to #show" do
      get("/venues/1").should_not be_routable
    end

    it "routes to #edit" do
      get("/venues/1/edit").should route_to("venues#edit", :id => "1")
    end

    it "routes to #create with location" do
      post("/locations/1/venues").should route_to("venues#create", :location_id => "1")
    end

    it "routes to #update" do
      put("/venues/1").should route_to("venues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/venues/1").should route_to("venues#destroy", :id => "1")
    end

  end
end
