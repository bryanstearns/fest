require "spec_helper"

describe Admin::LocationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      get("/admin/locations").should route_to("admin/locations#index")
    end

    it "routes to #new" do
      get("/admin/locations/new").should route_to("admin/locations#new")
    end

    it "routes to #show" do
      get("/admin/locations/1").should route_to("admin/locations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/locations/1/edit").should route_to("admin/locations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/locations").should route_to("admin/locations#create")
    end

    it "routes to #update" do
      put("/admin/locations/1").should route_to("admin/locations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/locations/1").should route_to("admin/locations#destroy", :id => "1")
    end

  end
end
