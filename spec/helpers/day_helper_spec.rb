require 'spec_helper'

describe DayHelper, type: :helper do
  helper DayHelper

  context "stepping time" do
    it "should yield the right steps" do
      t = Time.current.at("12:00")
      result = []
      hour_steps(t, t + 4.hours) {|x| result << x }
      result.should eq([t, t + 1.hour, t + 2.hours, t + 3.hours ])
    end
  end

  context "time labels" do
    it "should show midnight at 12am" do
      hour_label(Time.current.at("00:00")).should eq("mid")
    end
    it "should show noon at 12pm" do
      hour_label(Time.current.at("12:00")).should eq("noon")
    end
    it "should show an am/pm hour otherwise" do
      hour_label(Time.current.at("13:00")).should eq(" 1 pm")
    end
  end
end
