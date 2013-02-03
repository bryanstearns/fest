require "spec_helper"

describe QuestionsController do
  describe "routing" do
    it "routes to #new" do
      get("/feedback").should route_to("questions#new")
      get("/questions/new").should route_to("questions#new")
    end

    it "routes to #create" do
      post("/questions").should route_to("questions#create")
    end
  end
end
