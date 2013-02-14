require "spec_helper"

describe UserRatingsController do
  describe "routing" do
    it "routes to #show" do
      get("/ratings/2").should route_to("user_ratings#show", token: '2')
    end
  end
end
