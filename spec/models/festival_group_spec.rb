require 'rails_helper'

describe FestivalGroup do
  subject do
    fg = FestivalGroup.new
    fg << build(:festival, name: 'bashful', slug_group: 'doc', starts_on: '2011-01-01')
    fg << build(:festival, name: 'grumpy', slug_group: 'happy', starts_on: '2012-01-01')
    fg << build(:festival, name: 'sleepy', slug_group: 'dopey', starts_on: '2010-01-01')
  end

  it 'reports the name of the most recent festival added' do
    subject.name.should == 'grumpy'
  end

  it 'reports a slug group' do
    subject.festivals.map(&:slug_group).should include(subject.slug)
  end

  it 'returns festivals in reverse chronological order' do
    subject.festivals.map(&:starts_on).should == ["2012-01-01", "2011-01-01", "2010-01-01"].map(&:to_date)
  end

  it "reports the start date of its latest festival" do
    subject.latest_festival_start.should == '2012-01-01'.to_date
  end

  it "is comparable" do
    subject.should respond_to("<=>")
  end
end
