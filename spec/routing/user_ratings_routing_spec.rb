require "spec_helper"

describe UserRatingsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      get("/users/1/ratings/12345").should route_to("user_ratings#show", user_id: '1', id: '12345')
    end
    it "routes to #show the old way" do
      get("/ratings/12345").should route_to("user_ratings#show", id: '12345')
    end
  end
end
