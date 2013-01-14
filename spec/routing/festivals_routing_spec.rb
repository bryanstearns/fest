require "spec_helper"

describe FestivalsController do
  describe "routing" do
    it "routes to #index" do
      get("/festivals").should route_to("festivals#index")
    end

    it "routes to #show" do
      get("/festivals/1").should route_to("festivals#show", :id => "1")
    end

    it "routes #new to #show" do
      # we don't want to route #new, which means #new looks like a #show
      # get("/festivals/new").should_not be_routable
      get("/festivals/new").should route_to("festivals#show", :id => "new")
    end

    it "doesn't route to #create" do
      post("/festivals").should_not be_routable
    end

    it "doesn't route to #edit" do
      get("/festivals/1/edit").should_not be_routable
    end

    it "doesn't route to #update" do
      put("/festivals/1").should_not be_routable
    end

    it "doesn't route to #destroy" do
      delete("/festivals/1").should_not be_routable
    end
  end
end
