require 'spec_helper'

describe ApplicationHelper, type: :helper do
  helper ApplicationHelper

  context "current_user_is_admin?" do
    subject { helper.current_user_is_admin? }
    context "without user logged in" do
      before { allow(helper).to receive(:user_signed_in?).and_return(false) }
      it { should be_falsey }
    end
    context "with non-admin user logged in" do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).
                             and_return(build(:user, :admin => nil))
      end
      it { should be_falsey }
    end
    context "with admin user logged in" do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).
                             and_return(build(:user, :admin => true))
      end
      it { should be_truthy }
    end
  end

  context "current_user_is_ffff?" do
    subject { helper.current_user_is_ffff? }
    context "without user logged in" do
      before { allow(helper).to receive(:user_signed_in?).and_return(false) }
      it { should be_falsey }
    end
    context "with non-ffff user logged in" do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).
                             and_return(build(:user, :ffff => false))
      end
      it { should be_falsey }
    end
    context "with ffff user logged in" do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).
                             and_return(build(:user, :ffff => true))
      end
      it { should be_truthy }
    end
  end

  context "A formatted date range" do
    subject { date_range(start_on, end_on) }
    let(:start_on) { Date.parse("2015-11-20") }

    context "for a single date" do
      let(:end_on) { start_on }
      it { should == "November 20, 2015" }
    end

    context "for dates within a month" do
      let(:end_on) { start_on + 3 }
      it { should == "November 20 - 23, 2015" }
    end

    context "for cross-month dates within a year" do
      let(:end_on) { start_on + 30 }
      it { should == "November 20 - December 20, 2015" }
    end

    context "for cross-year dates" do
      let(:end_on) { start_on + 60 }
      it { should == "November 20, 2015 - January 19, 2016" }
    end

    context "for unset dates" do
      let(:end_on) { nil }
      it { should be_nil }
    end

    context "when passed an object" do
      subject { date_range(object) }
      context "that responds to #starts_on and #ends_on" do
        let(:object) { double(:starts_on => start_on,
                              :ends_on => start_on + 2.days) }
        it "should ask the object" do
          subject.should == "November 20 - 22, 2015"
        end
      end
      context "that responds to #starts_at and #ends_at" do
        let(:object) { double(:starts_at => start_on.at("2:00"),
                              :ends_at => (start_on + 3.days).at("17:00")) }
        it "should ask the object" do
          subject.should == "November 20 - 23, 2015"
        end
      end
    end
  end

  context "A formatted time range, not showing the date" do
    subject { time_range(start_at, end_at) }
    let(:start_at) { Time.zone.parse("2015-11-20 9:45") }

    context "for a single time" do
      let(:end_at) { start_at }
      it { should == "9:45 am" }
    end

    context "for times within a meridian" do
      let(:end_at) { start_at + 30.minutes }
      it { should == "9:45 - 10:15 am" }
    end

    context "for cross-meridian dates on the same day" do
      let(:end_at) { start_at + 5.hours }
      it { should == "9:45 am - 2:45 pm" }
    end

    context "for cross-day times" do
      let(:end_at) { start_at + 17.hours }
      it { should == "9:45 am - 2:45 am" }
    end

    context "for unset times" do
      let(:end_at) { nil }
      it { should be_nil }
    end

    context "when passed an object" do
      subject { time_range(object) }
      context "that responds to #starts_at and #ends_at" do
        let(:object) { double(:starts_at => start_at,
                              :ends_at => start_at + 2.hours) }
        it "should ask the object" do
          subject.should == "9:45 - 11:45 am"
        end
      end
    end
  end

  context "A link in a list that might be active" do
    subject { helper.link_in_list_to("Title", "some_target") }
    context "when on the current page" do
      it "should produce a li with class 'active'" do
        allow(helper).to receive(:current_page?).and_return(true)
        expect(subject).to match(/^<li class="active">/)
      end
    end
    context "when not on the current page" do
      it "should produce a li without class 'active'" do
        allow(helper).to receive(:current_page?).and_return(false)
        expect(subject).to match(/^<li>/)
      end
    end
  end

  context "generating flag icons" do
    it "produce image tags for each country given" do
      helper.flags("us de").should == \
        "<img alt=\"United States\" class=\"flag flag-us\" src=\"/assets/blank.gif\" title=\"United States\" />" +
          "<img alt=\"Germany\" class=\"flag flag-de\" src=\"/assets/blank.gif\" title=\"Germany\" />"
    end
  end
  context "generating country names" do
    it "returns a comma-separated list" do
      helper.country_names("fr ca").should == "France, Canada"
    end
  end
end
