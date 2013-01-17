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

describe 'Time rounding' do
  subject { Time.current.at("12:40") }
  it "should round up, to the next hour by default" do
    subject.round_up.should == subject.at("13:00")
  end
  it "should round down, to the previous hour by default" do
    subject.round_down.should == subject.at("12:00")
  end
  it "should round up, to a specified increment" do
    subject.round_up(15).should == subject.at("12:45")
  end
  it "should round down, to a specified increment" do
    subject.round_down(15).should == subject.at("12:30")
  end
  it "shouldn't change when already rounded (up)" do
    subject.round_up(10).should == subject
  end
  it "shouldn't change when already rounded (down)" do
    subject.round_down(10).should == subject
  end
end

describe 'Time#to_minutes' do
  it "should know how many minutes into today we are" do
    Time.current.at("12:30:59").to_minutes.should == ((12 * 60) + 30)
    Time.current.at("0").to_minutes.should == 0
  end
end

describe 'Fixnum#to_minutes' do
  it "Should just divide by 60" do
    (130 * 60).to_minutes.should eq(130)
  end
end

describe 'Float#to_minutes' do
  it "Should calculate minutes from a duration" do
    now = Time.current
    earlier = now - 30.minutes
    (now - earlier).to_minutes.should eq(30)
  end
end

describe 'Numeric#in_words' do
  it "should use 'no' for zero" do
    0.in_words.should == 'no'
  end
  it "should use words for small numbers" do
    5.in_words.should == 'five'
  end
  it "should use numbers for large numbers" do
    11.in_words.should == '11'
  end
end
describe 'Numeric#counted' do
  it "should pluralize" do
    2.counted('octopus').should == 'two octopi'
  end
  it "should singularize" do
    1.counted('octopus').should == 'one octopus'
  end
end

describe 'Enumerable#map_by' do
  let(:a) { mock(x: 5) }
  let(:b) { mock(x: 12) }
  let(:c) { mock(x: 7) }
  let(:enumerable) { [ a, b, c ] }
  context "when given an symbol" do
    subject { enumerable.map_by(:x) }
    it "builds a hash by that attribute" do
      subject.should == { 5 => a, 12 => b, 7 => c }
    end
  end
  context "when given a block" do
    subject { enumerable.map_by {|i| i.x * 2 } }
    it "builds a hash by its result " do
      subject.should == { 10 => a, 24 => b, 14 => c }
    end
  end
end
