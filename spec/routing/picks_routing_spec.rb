require "spec_helper"

describe PicksController do
  describe "routing" do
    it "routes to #index" do
      get("/festivals/1/priorities").should route_to("picks#index", :festival_id => "1")
    end
    it "routes to #create" do
      post("/films/1/picks").should route_to("picks#create", :film_id => "1")
    end
  end
end
