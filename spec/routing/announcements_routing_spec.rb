require "spec_helper"

describe AnnouncementsController do
  describe "routing" do

    it "routes to #index" do
      get("/announcements").should route_to("announcements#index")
    end

    it "routes to #show" do
      get("/announcements/1").should route_to("announcements#show", :id => "1")
    end
  end
end
