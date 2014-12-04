require 'spec_helper'

describe FilmsHelper, type: :helper do
  helper FilmsHelper

  describe "translating duration" do
    it "should use minutes for less than an hour" do
      helper.hours_and_minutes(36.minutes).should == "36 minutes"
    end

    it "should use hours and minutes for an hour or more" do
      helper.hours_and_minutes(97.minutes).should == "1 hour 37 minutes"
    end

    it "shouldn't mention minutes for even hours" do
      helper.hours_and_minutes(120.minutes).should == "2 hours"
    end
  end
end
