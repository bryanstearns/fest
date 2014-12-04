require "spec_helper"

describe SubscriptionsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      get("/festivals/1/assistant").should route_to("subscriptions#show", :festival_id => "1")
    end

    it "routes to #update" do
      put("/festivals/1/assistant").should route_to("subscriptions#update", :festival_id => "1")
    end
  end
end
