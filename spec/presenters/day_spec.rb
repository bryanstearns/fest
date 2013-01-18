require 'spec_helper'

describe Day do
  let(:day_count) { 2 }
  let(:festival) { create(:festival, :with_films_and_screenings, day_count: day_count) }
  let(:helper) { Object.new.extend(FestivalsHelper) }

  context "collecting from a festival" do
    subject {
      helper.days(festival)
    }
    it "should return a day for each date, in order" do
      subject.should have(day_count).items
      subject.map(&:date).should eq((festival.starts_on .. festival.ends_on).to_a)
    end

    it "should paginate when a day overflows" do
      page_height = 0
      subject.each do |day|
        broke = (page_height + day.grid_height +
                 Day::DAY_HEADER_HEIGHT) > Day::PAGE_HEIGHT
        day.page_break_before.should eq(broke)
        page_height = day.grid_height if broke
      end
    end
  end

  context ViewingPositioner do
    let(:day_start) { Time.current.at("12:00") }
    subject { ViewingPositioner.new(day_start) }

    context "with one screening near the start of a day in a venue" do
      let(:s1) { double(starts_at: day_start.at("12:05"),
                        duration: 55.minutes,
                        venue: "v1") }
      let(:p1) { subject.position_for(s1) }

      it "should position it correctly" do
        p1.should eq([ColumnKey.new("v1", 0), 5])
      end

      context "and another screening in the same venue, unconflicting" do
        let(:s2) { double(starts_at: day_start.at("13:05"),
                          duration: 55.minutes,
                          venue: "v1") }
        let(:p2) { subject.position_for(s2) }
        it "should position them in the same venue & room" do
          p1.first.venue.should eq(p2.first.venue)
        end
      end

      context "and another screening in the same venue, conflicting" do
        let(:s2) { double(starts_at: day_start.at("11:05"),
                          duration: 55.minutes,
                          venue: "v1") }
        let(:p2) { subject.position_for(s2) }
        it "should position them in the different rooms of the same venue" do
          p1.first.venue.should eq(p2.first.venue)
          p1.first.index.should_not eq(p2.first.index)
        end
      end

      context "and another screening in the a different venue, conflicting" do
        let(:s2) { double(starts_at: day_start.at("11:05"),
                          duration: 55.minutes,
                          venue: "v2") }
        let(:p2) { subject.position_for(s2) }
        it "should position them in different venues" do
          p1.first.venue.should_not eq(p2.first.venue)
        end
      end
    end
  end

  context "A single day" do
    subject { build(:day, festival: festival) }

    it "should know its date" do
      subject.date.should eq(festival.starts_on)
    end

    it "should know its screening time range" do
      screenings = festival.screenings.on(festival.starts_on)
      subject.starts_at.should eq(screenings.map(&:starts_at).min.round_down)
      subject.ends_at.should eq(screenings.map(&:ends_at).max.round_up)
    end

    it "should know its column names, in order" do
      # this only tests the case where we're not mapping to virtual venues...
      subject.column_names.should \
        eq(subject.screenings.map {|s| s.venue.name }.uniq.sort)
    end

    it "should produce each venue's viewings" do
      subject.column_viewings do |viewings|
        viewings.map(&:screening).should \
          eq(subject.screenings.select {|s| s.venue == venue })
      end
    end

    it "should know the day height" do
      subject.grid_height.should eq((subject.ends_at -
                                      subject.starts_at).to_minutes *
                                    Day::MINUTE_HEIGHT)
    end

    it "should know the column width percentage" do
      subject.column_width.should eq(100 / subject.column_names.count)
    end
  end
end
