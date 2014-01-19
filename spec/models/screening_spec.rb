require 'spec_helper'

describe Screening do
  let(:user) { create(:user) }
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
      subject.ends_at.should eq(subject.starts_at + subject.film.duration)
    end

    it "should know its duration" do
      subject.duration.should eq(subject.film.duration)
    end

    it "should know its film's name" do
      subject.name.should eq(subject.film.name)
    end

    it "should know if it's yet to happen" do
      subject.should_not be_future # tests #future?
    end
  end

  describe "testing for conflict" do
    subject { build(:screening, festival_id: 1).tap {|s| s.send(:assign_ends_at) } }
    let(:other) do
      build(:screening,
            { festival: subject.festival }.merge(other_options)).tap do |s|
         s.send(:assign_ends_at)
      end
    end

    # Better readability...
    RSpec::Matchers.define :not_conflict_with do |expected, user|
      match {|actual| actual.conflicts_with?(expected, user.id).should be_false }
    end
    RSpec::Matchers.define :conflict_with do |expected, user|
      match {|actual| actual.conflicts_with?(expected, user.id).should be_true }
    end

    context "with itself" do
      it { should not_conflict_with(subject, user) }
    end
    context "with another ending well before this starts" do
      let(:other_options) { { starts_at: subject.starts_at - 400.minutes } }
      it { should not_conflict_with(other, user) }
    end
    context "with another starting well after this ends" do
      let(:other_options) { { starts_at: subject.ends_at + 121.minutes } }
      it { should not_conflict_with(other, user) }
    end
    context "with another in the same venue" do
      let(:other_options) { { venue_id: subject.venue_id } }
      it { should not_conflict_with(other, user) }
    end
    context "with another at a different festival" do
      let(:other_options) { { festival: nil } }
      it { should not_conflict_with(other, user) }
    end
    context "with another at a conflicting time" do
      let(:other_options) { { starts_at: subject.starts_at + 10.minutes } }
      it { should conflict_with(other, user) }
    end
  end
end
