require 'spec_helper'

describe Screening do
  context "validations" do
    subject { build(:screening) }

    it { should validate_presence_of(:film_id) }
    it { should validate_presence_of(:venue_id) }
    it { should validate_presence_of(:starts_at) }

    it "should set location automatically from venue" do
      subject.location = nil
      subject.should be_valid
      subject.location.should eq(subject.venue.location)
    end

    it "should set festival automatically from film" do
      subject.festival = nil
      subject.should be_valid
      subject.festival.should eq(subject.film.festival)
    end

    it "should set ends_at automatically from film duration" do
      subject.ends_at = nil
      subject.should be_valid
      subject.ends_at.should eq(subject.starts_at + subject.film.duration.minutes)
    end

    it "should know its duration" do
      subject.duration.should eq(subject.film.duration)
    end

    it "should know its film's name" do
      subject.name.should eq(subject.film.name)
    end
  end
end
