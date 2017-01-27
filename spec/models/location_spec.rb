require 'rails_helper'

describe Location do
  subject { build(:location, name: "My Location") }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:place) }
  it { should validate_uniqueness_of(:name).scoped_to(:place) }

  it "generates a googleable address if the address is blank" do
    expect(subject.googleable_address).to eq("My Location, Portland, Oregon")
  end

  context "when it has an address" do
    subject { build(:location, address: "1221 SW 4th, Portland OR") }
    it "returns the address it has" do
      expect(subject.googleable_address).to eq("1221 SW 4th, Portland OR")
    end
  end

  it "reports its parking time" do
    expect(subject.parking_minutes).to eq(12)
  end
end
