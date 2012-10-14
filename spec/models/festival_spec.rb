require 'spec_helper'

describe Festival do
  context "validations" do
    subject { build(:festival) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:slug_group) }
    it "should set slug automatically" do
      subject.valid?
      subject.slug.should == "#{subject.slug_group}_#{subject.starts_on.strftime("%Y")}"
    end
  end
end
