require 'spec_helper'

describe Location do
  subject { build(:location) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:place) }
  it { should validate_uniqueness_of(:name).scoped_to(:place) }
end
