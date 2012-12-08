require 'spec_helper'

describe ApplicationHelper do
  helper ApplicationHelper

  context "current_user_is_admin?" do
    subject { helper.current_user_is_admin? }
    context "without user logged in" do
      before { helper.stub(user_signed_in?: false) }
      it { should be_false }
    end
    context "with non-admin user logged in" do
      before do
        helper.stub(user_signed_in?: true)
        helper.stub(current_user: build(:user, :admin => nil))
      end
      it { should be_false }
    end
    context "with admin user logged in" do
      before do
        helper.stub(user_signed_in?: true)
        helper.stub(current_user: build(:user, :admin => true))
      end
      it { should be_true }
    end
  end

  context "A formatted date range" do
    subject { date_range(start_on, end_on) }
    let(:start_on) { Date.parse("2015-11-20") }

    context "for a single date" do
      let(:end_on) { start_on }
      it { should == "Nov 20, 2015" }
    end

    context "for dates within a month" do
      let(:end_on) { start_on + 3 }
      it { should == "Nov 20 - 23, 2015" }
    end

    context "for cross-month dates within a year" do
      let(:end_on) { start_on + 30 }
      it { should == "Nov 20 - Dec 20, 2015" }
    end

    context "for cross-year dates" do
      let(:end_on) { start_on + 60 }
      it { should == "Nov 20, 2015 - Jan 19, 2016" }
    end

    context "for unset dates" do
      let(:end_on) { nil }
      it { should be_nil }
    end
  end

  context "A link in a list that might be active" do
    subject { helper.link_in_list_to("Title", "some_target") }
    context "when on the current page" do
      it "should produce a li with class 'active'" do
        helper.stub(:current_page? => true)
        helper.should_receive(:content_tag).with(:li, anything, class: "active")
        subject
      end
    end
    context "when not on the current page" do
      it "should produce a li without class 'active'" do
        helper.stub(:current_page? => false)
        helper.should_not_receive(:content_tag).with(:li, anything, class: "active")
        subject
      end
    end
  end
end