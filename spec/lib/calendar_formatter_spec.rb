require 'rails_helper'

describe CalendarFormatter do
  let(:screening_time) { 2.weeks.from_now }
  let(:screening) { create(:screening, starts_at: screening_time) }
  let(:screenings) { [screening] }
  let(:formatter) { CalendarFormatter.new("Bob", screenings) }
  let(:output) { formatter.to_ics }
  let(:calendar) { Icalendar::Calendar.parse(output).first }
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
    context "with no screenings at all" do
      let(:screenings) { [] }
      it "should still produce a parsable calendar" do
        expect(calendar).to be_an_instance_of(Icalendar::Calendar)
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
      event.url.to_s.should eq("http://localhost:3000/festivals/#{screening.festival.slug}#s#{screening.id}")
    end

    it "should point at the festival screening page" do
      event.description.to_s.should eq("description\n\nhttps://example.com/fragment")
    end
  end
end
