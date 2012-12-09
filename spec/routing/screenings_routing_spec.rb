require "spec_helper"

describe ScreeningsController do
  describe "routing" do

    it "routes to #index with film" do
      get("/films/1/screenings").should route_to("screenings#index", :film_id => "1")
    end

    it "routes to #new with film" do
      get("/films/1/screenings/new").should route_to("screenings#new", :film_id => "1")
    end

    it "routes to #show" do
      get("/screenings/1").should route_to("screenings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/screenings/1/edit").should route_to("screenings#edit", :id => "1")
    end

    it "routes to #create with film" do
      post("/films/1/screenings").should route_to("screenings#create", :film_id => "1")
    end

    it "routes to #update" do
      put("/screenings/1").should route_to("screenings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/screenings/1").should route_to("screenings#destroy", :id => "1")
    end

  end
end
