require "spec_helper"

describe UserCalendarsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      get("/users/1/calendar/12345.ics").should route_to("user_calendars#show", user_id: '1', id: '12345', format: 'ics')
    end
  end
end
