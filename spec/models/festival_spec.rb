require 'spec_helper'

describe Festival do
  context "validations" do
    subject { build(:festival) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:slug_group) }
  end
end
