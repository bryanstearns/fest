require 'rails_helper'

describe Restriction do
  let(:items) do
    [
      build(:restriction,
            starts_at: Time.zone.parse("2013/2/4")),
      build(:restriction,
            starts_at: Time.zone.parse("2013/2/6").at("20"),
            ends_at: Time.zone.parse("2013/2/6").at("22"))
    ]
  end
  let(:items_serialized) { '2/4, 2/6 8pm-10pm' }

  context 'serializing to text' do
    it 'handles an array of restrictions' do
      Restriction.dump(items).should == items_serialized
    end
    it 'handles an empty array' do
      Restriction.dump([]).should be_nil
    end
  end

  context 'loading from text' do
    it 'produces an array of restrictions' do
      Restriction.load(items_serialized, Date.parse('1/1/2013')).should eq(items)
    end
  end

  context 'testing for overlap' do
    it 'returns true for overlapping restrictions' do
      overlapping = build(:restriction,
        starts_at: Time.zone.parse("2013/2/4").at("20"),
        ends_at: Time.zone.parse("2013/2/4").at("22"))

      items.first.overlaps?(overlapping).should be_truthy
    end
    it 'returns false for non-overlapping restrictions' do
      items.first.overlaps?(items.last).should be_falsey
    end
  end
end
