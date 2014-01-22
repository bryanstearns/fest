require 'spec_helper'

describe CalendarFormatter do
  before(:all) do
    @screening = create(:screening)
    @formatter = CalendarFormatter.new([@screening])
    @output = @formatter.to_ics
    @calendar = Icalendar.parse(@output).first
    @event = @calendar.events.first
  end

  context "the calendar" do
    it "should point at the site" do
      @calendar.prodid.should eq("localhost:3000")
    end
  end

  context "the screening" do
    it "should be for the right film" do
      @event.summary.should eq(@screening.name)
    end

    it "should be at the right location" do
      @event.location.should eq(@screening.venue_name)
    end

    it "should start at the screening start time" do
      @event.dtstart.should eq(@screening.starts_at + Time.zone.utc_offset)
    end

    it "should end at the screening end time" do
      @event.dtend.should eq(@screening.ends_at + Time.zone.utc_offset)
    end

    it "should reflects the screening's created-at time" do
      @event.created.to_i.should eq((@screening.created_at + Time.zone.utc_offset).to_i)
    end

    it "should reflects the screening's updated-at time" do
      @event.last_modified.to_i.should eq((@screening.updated_at + Time.zone.utc_offset).to_i)
    end

    it "should point at the screening" do
      @event.url.to_s.should eq("http://localhost:3000/festivals/#{@screening.festival_id}#s#{@screening.id}")
    end
  end
end
