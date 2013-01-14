require "spec_helper"

describe Admin::FilmsController do
  describe "routing" do
    it "routes to #index with festival" do
      get("/admin/festivals/1/films").should route_to("admin/films#index", festival_id: "1")
    end

    it "routes to #new with festival" do
      get("/admin/festivals/1/films/new").should route_to("admin/films#new", festival_id: "1")
    end

    it "routes to #show" do
      get("/admin/films/1").should route_to("admin/films#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/films/1/edit").should route_to("admin/films#edit", :id => "1")
    end

    it "routes to #create with festival" do
      post("/admin/festivals/1/films").should route_to("admin/films#create", festival_id: "1")
    end

    it "routes to #update" do
      put("/admin/films/1").should route_to("admin/films#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/films/1").should route_to("admin/films#destroy", :id => "1")
    end
  end
end
