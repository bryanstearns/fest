require "spec_helper"

describe Admin::ScreeningsController, type: :routing do
  describe "routing" do
    it "doesn't route to #index" do
      get("/admin/screenings").should_not be_routable
    end

    it "doesn't route to #show" do
      get("/admin/screenings/1").should_not be_routable
    end

    it "routes to #new with film" do
      get("/admin/films/1/screenings/new").should route_to("admin/screenings#new", :film_id => "1")
    end

    it "routes to #create with film" do
      post("/admin/films/1/screenings").should route_to("admin/screenings#create", :film_id => "1")
    end

    it "routes to #edit" do
      get("/admin/screenings/1/edit").should route_to("admin/screenings#edit", :id => "1")
    end

    it "routes to #update" do
      put("/admin/screenings/1").should route_to("admin/screenings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/screenings/1").should route_to("admin/screenings#destroy", :id => "1")
    end
  end
end
