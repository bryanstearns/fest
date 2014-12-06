require 'spec_helper'

describe CalendarFormatter do
  let(:screening_time) { 2.weeks.from_now }
  let(:screening) { create(:screening, starts_at: screening_time) }
  let(:formatter) { CalendarFormatter.new("Bob", [screening]) }
  let(:output) { formatter.to_ics }
  let(:calendar) { Icalendar.parse(output).first }
  let(:event) { calendar.events.first }

  context "the calendar" do
    it "should point at the site" do
      calendar.prodid.should eq("localhost:3000")
    end

    it "should have a name" do
      calendar.x_wr_calname.should eq(["Bob's Screenings on Festival Fanatic"])
    end

    context "with an upcoming screening" do
      it "should have a short refresh interval" do
        calendar.x_published_ttl.should eq(["PT4H"])
      end
    end
    context "with no upcoming screenings" do
      let(:screening_time) { 11.months.ago }
      it "should have a long refresh interval" do
        calendar.x_published_ttl.should eq(["P2D"])
      end
    end
  end

  context "the screening" do
    it "should be for the right film" do
      event.summary.should eq(screening.name)
    end

    it "should be at the right location" do
      event.location.should eq(screening.venue_name)
    end

    it "should start at the screening start time" do
      event.dtstart.to_i.should eq(screening.starts_at.to_i)
    end

    it "should end at the screening end time" do
      event.dtend.to_i.should eq(screening.ends_at.to_i)
    end

    it "should reflects the screening's created-at time" do
      event.created.to_i.should eq(screening.created_at.to_i)
    end

    it "should reflects the screening's updated-at time" do
      event.last_modified.to_i.should eq(screening.updated_at.to_i)
    end

    it "should point at the screening" do
      event.url.to_s.should eq("http://localhost:3000/festivals/#{screening.festival_id}#s#{screening.id}")
    end
  end
end
