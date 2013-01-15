require 'spec_helper'

describe User do
  it "should create a new user given valid attributes" do
    User.create!(attributes_for(:user))
  end

  context "festival subscription lookup" do
    let(:festival) { create(:festival, :with_films_and_screenings) }
    subject { create(:user) }

    describe "when told to create one for a festival" do
      describe "and none exists" do
        it "creates one" do
          expect {
            subject.subscription_for(festival, create: true)
          }.to change(subject.subscriptions, :count).by(1)
        end
      end

      describe "and one exists" do
        let!(:existing) { create(:subscription, user: subject,
                                 festival: festival) }
        it "finds it" do
          expect {
            subject.subscription_for(festival,
                                     create: true).should eq(existing)
          }.to change(subject.subscriptions, :count).by(0)
        end
      end
    end

    describe "when not told to create one" do
      describe "and one doesn't exist" do
        it "returns Nil" do
          subject.subscription_for(festival).should be_nil
        end
      end
      describe "and one exists already" do
        let!(:existing) { create(:subscription, user: subject,
                                 festival: festival) }
        it "finds it" do
          expect {
            subject.subscription_for(festival).should eq(existing)
          }.to change(subject.subscriptions, :count).by(0)
        end
      end
    end

    describe "checking for screenings" do
      describe "and there aren't any" do
        it "returns false" do
          subject.has_screenings_for?(festival).should be_false
        end
      end
      describe "and there's at least one" do
        let(:screening) { festival.screenings.first }
        let(:film) { screening.film }
        let!(:pick) { create(:pick, festival: festival, user: subject,
                             film: film, screening: screening ) }
        it "returns true" do
          subject.has_screenings_for?(festival).should be_true
        end
      end
    end

    describe "checking for priorites" do
      describe "and there aren't any" do
        it "returns false" do
          subject.has_priorities_for?(festival).should be_false
        end
      end
      describe "and there's at least one" do
        let(:film) { festival.films.first }
        let!(:pick) { create(:pick, festival: festival, user: subject,
                             film: film, priority: 1) }
        it "returns true" do
          subject.has_priorities_for?(festival).should be_true
        end
      end
    end
  end
end
