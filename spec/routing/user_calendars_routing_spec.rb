require "spec_helper"

describe UserCalendarsController do
  describe "routing" do
    it "routes to #show" do
      get("/calendars/12345.ics").should route_to("user_calendars#show", token: '12345', format: 'ics')
    end
  end
end
