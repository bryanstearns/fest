require "spec_helper"

describe FilmsController do
  describe "routing" do

    it "routes to #index with festival" do
      get("/festivals/1/films").should route_to("films#index", festival_id: "1")
    end

    it "routes to #new with festival" do
      get("/festivals/1/films/new").should route_to("films#new", festival_id: "1")
    end

    it "routes to #show" do
      get("/films/1").should route_to("films#show", :id => "1")
    end

    it "routes to #edit" do
      get("/films/1/edit").should route_to("films#edit", :id => "1")
    end

    it "routes to #create with festival" do
      post("/festivals/1/films").should route_to("films#create", festival_id: "1")
    end

    it "routes to #update" do
      put("/films/1").should route_to("films#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/films/1").should route_to("films#destroy", :id => "1")
    end

  end
end
