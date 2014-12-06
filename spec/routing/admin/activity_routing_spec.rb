require "spec_helper"

describe Admin::ActivityController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      get("/admin/activity").should route_to("admin/activity#index")
    end
    it "routes to #index for a user" do
      get("/admin/users/1/activity").should route_to("admin/activity#index", user_id: '1')
    end
  end
end
