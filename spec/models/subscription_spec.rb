require 'rails_helper'

describe Subscription do
  subject { build(:subscription) }

  describe "checking visibility" do
    let(:festival) { create(:festival, :with_films_and_screenings,
                            press: true) }
    let(:screening) { festival.screenings.where(press: is_press).first }
    context "of normal screenings" do
      let(:is_press) { false }
      it "returns true" do
        subject.can_see?(screening).should be_truthy
      end
    end
    context "of press screenings" do
      let(:is_press) { true }
      it "returns false by default" do
        subject.can_see?(screening).should be_falsey
      end
      context "and the user does't want press screenings" do
        it "returns false" do
          subject.can_see?(screening).should be_falsey
        end
      end
      context "and the user has asked for press screenings" do
        subject { build(:subscription, show_press: true) }
        it "returns true" do
          subject.can_see?(screening).should be_truthy
        end
      end
    end
  end

  context 'assigning sharing keys' do
    it 'generates a key' do
      key = Subscription.generate_key
      key.should match(/^[0-9a-f]{8}$/)
      key.should_not eq(Subscription.generate_key)
    end
    it 'assigns the key on first use' do
      subject.key.should_not be_nil
    end
    it 'assigns the key on first save' do
      subject.save!
      key = subject.key
      subject.reload
      subject.key.should eq(key)
    end
    it 'assigns the ratings token on first use' do
      subject.ratings_token.should_not be_nil
    end
    it 'assigns the ratings token on first save' do
      subject.save!
      ratings_token = subject.ratings_token
      subject.reload
      subject.ratings_token.should eq(ratings_token)
    end
  end

  context "location exclusions" do
    let(:festival) { create(:festival, :with_venues,
                            location_count: 2)}
    subject { build(:subscription, festival: festival)}
    it 'get the list of all IDs from the festival' do
      subject.festival_location_ids.count.should == 2
      subject.festival_location_ids.should \
        eq(festival.locations.map(&:id))
    end

    it 'reports the list of included location IDs' do
      allow(subject).to receive(:festival_location_ids).and_return([1,2,5,6])
      subject.excluded_location_ids = [2, 6]
      subject.included_location_ids.should eq([1, 5])
    end
    it 'accepts a list of included location IDs' do
      allow(subject).to receive(:festival_location_ids).and_return([1,2,5,6])
      subject.included_location_ids = [6, 1]
      subject.excluded_location_ids.should eq([2, 5])
    end

    it 'validates that some locations are included' do
      subject.included_location_ids = []
      subject.should_not be_valid
      subject.should have(1).errors_on(:excluded_location_ids)
      subject.included_location_ids = [festival.locations.first.id]
      subject.should be_valid
    end
  end
end
