require 'spec_helper'

describe 'Time#at' do
  subject { Time.now }
  it { should be_a(Time) }
  it "should replace the time on a Time from a string" do
    subject.at("3:12").should eq(subject.change(hour: 3, min: 12, sec: 0))
  end
  it "should replace the time on a Time from another time" do
    subject.at("2/1/2012 15:17".to_time).should \
      eq(subject.change(hour: 15, min: 17, sec: 0))
  end
end
# Make sure it works for TimeWithZone, too
describe 'TimeWithZone#at' do
  subject { Time.current }
  it { should be_a(ActiveSupport::TimeWithZone) }
  it "should replace the time on a TimeWithZone from a string" do
    subject.at("23").should eq(subject.change(hour: 23, min: 0, sec: 0))
  end
  it "should replace the time on a TimeWithZone from another time" do
    subject.at("2/1/2012 15:17".to_time).should \
      eq(subject.change(hour: 15, min: 17, sec: 0))
  end
end
# And date
describe 'Date#at' do
  subject { Date.today }
  it { should be_a(Date) }
  it "should set the time on a Date from a string" do
    subject.at("23").should eq(subject.to_time_in_current_zone\
                                      .change(hour: 23, min: 0, sec: 0))
  end
  it "should set the time on a Date from another time" do
    subject.at("2/1/2012 15:17".to_time).should \
      eq(subject.to_time_in_current_zone.change(hour: 15, min: 17, sec: 0))
  end
end
