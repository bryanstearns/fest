require 'spec_helper'

describe FestivalGroup do
  subject do
    fg = FestivalGroup.new
    fg << build(:festival, name: 'bashful', slug_group: 'doc', starts_on: "2011-01-01")
    fg << build(:festival, name: 'grumpy', slug_group: 'happy', starts_on: "2012-01-01")
    fg << build(:festival, name: 'sleepy', slug_group: 'dopey', starts_on: "2010-01-01")
  end

  it "should report the name of the most recent festival added" do
    subject.name.should == "grumpy"
  end

  it "should report a slug group (but any one is ok)" do
    subject.festivals.map(&:slug_group).should include(subject.slug)
  end

  it "should return festivals in reverse chronological order" do
    subject.festivals.map(&:starts_on).should == ["2012-01-01", "2011-01-01", "2010-01-01"].map(&:to_date)
  end
end
