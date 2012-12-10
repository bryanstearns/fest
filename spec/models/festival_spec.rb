require 'spec_helper'

describe Festival do
  context "when built" do
    subject { build(:festival) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:slug_group) }
    it { should validate_presence_of(:starts_on) }
    it { should validate_presence_of(:ends_on) }

    it "should validate that dates are sequential" do
      subject.should be_valid
      subject.ends_on = subject.starts_on - 2
      subject.should_not be_valid
    end

    it "should set slug automatically" do
      subject.valid?
      subject.slug.should == "#{subject.slug_group}_#{subject.starts_on.strftime("%Y")}"
    end
  end
end
