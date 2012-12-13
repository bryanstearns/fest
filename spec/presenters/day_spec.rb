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
  end

  context "A single day" do
    subject { helper.days(festival).first }

    it "should know its date" do
      subject.date.should eq(festival.starts_on)
    end

    it "should know its screening time range" do
      screenings = festival.screenings.on(festival.starts_on)
      subject.starts_at.should eq(screenings.map(&:starts_at).min.round_down)
      subject.ends_at.should eq(screenings.map(&:ends_at).max.round_up)
    end
  end
end
