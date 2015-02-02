require 'spec_helper'

describe Film do
  let(:festival) { create(:festival, :with_films) }

  context "validation" do
    subject { build(:film, festival: festival) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:festival_id) }
    it { should validate_presence_of(:duration_minutes) }
    it { should validate_numericality_of(:duration_minutes) }

    it "should accept duration in minutes" do
      subject.duration_minutes = 15
      subject.duration.should == 15.minutes
    end

    it "should accept duration in hours and minutes" do
      subject.duration_minutes = "1:15"
      subject.duration.should == 75.minutes
    end

    it "should report duration in minutes" do
      subject.duration = 27.minutes
      subject.duration_minutes.should == 27
    end

    it "should validate duration_minutes if specified" do
      subject.duration_minutes = "blurf"
      subject.should_not be_valid
      subject.should have(1).error_on(:duration_minutes)
    end
  end

  context "retrieving by name" do
    subject { festival.films }

    it "returns them in sorted order" do
      subject.by_name.map(&:name).should eq(subject.map(&:name).sort)
    end
  end

  [:short_name, :sort_name].each do |attr|
    context "when #{attr} is not set" do
      subject { build(:film, festival: festival,
                      name: "Young Frankenstein",
                      attr => '') }
      it "defaults to the name" do
        subject.should be_valid
        subject.send(attr).should == "Young Frankenstein"
      end
    end
  end

  context "when the duration changes" do
    let(:screening) { create(:screening) }
    subject { screening.film.reload }
    it "should update screenings" do
      expect(screening.ends_at - screening.starts_at).to eq(subject.duration)
      subject.duration += 2.minutes
      subject.save!
      screening.reload
      expect(screening.ends_at - screening.starts_at).to eq(subject.duration)
    end
  end
end
