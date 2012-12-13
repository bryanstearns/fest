require 'spec_helper'

describe Festival do
  context "when built" do
    subject { build(:festival) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:slug_group) }
    it { should validate_presence_of(:starts_on) }
    it { should validate_presence_of(:ends_on) }

    # it { should validate_presence_of(:revised_at) }
    # Can't do the above because we've got a before_validation on: :create
    # that defaults it. Instead, check after it's been saved.
    it "should validate presence of revised_at" do
      subject.save!
      subject.revised_at = nil
      subject.should_not be_valid
      subject.errors.should have_key(:revised_at)
    end

    it "should validate that dates are sequential" do
      subject.should be_valid
      subject.ends_on = subject.starts_on - 2
      subject.should_not be_valid
    end

    it "should set slug automatically" do
      subject.valid?
      subject.slug.should == "#{subject.slug_group}_#{subject.starts_on.strftime("%Y")}"
    end

    it "should group screenings by date" do
      festival = build_stubbed(:festival)
      s1 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("12"))
      s2 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("13"))
      s3 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("14") + 1.day)
      ordered = double()
      ordered.should_receive(:order).with(:starts_at).and_return([s1, s2, s3])
      festival.should_receive(:screenings).and_return(ordered)
      festival.screenings_by_date.should eq({
        festival.starts_on => [s1, s2],
        festival.starts_on + 1 => [s3],
      })
    end
  end
end
