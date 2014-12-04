require "spec_helper"

describe PicksController, type: :routing do
  describe "routing" do
    it "routes /priorities to #index with festival" do
      get("/festivals/1/priorities").should route_to("picks#index", :festival_id => "1")
    end

    it "doesn't route to #show" do
      get("/picks/1").should_not be_routable
    end

    it "doesn't route to #new" do
      get("/picks/new").should_not be_routable
    end

    it "routes to #create with film" do
      post("/films/1/picks").should route_to("picks#create", :film_id => "1")
    end

    it "doesn't route to #edit" do
      get("/picks/1").should_not be_routable
    end

    it "doesn't route to #update" do
      put("/picks").should_not be_routable
    end

    it "doesn't route to #destroy" do
      delete("/picks/1").should_not be_routable
    end

  end
end
