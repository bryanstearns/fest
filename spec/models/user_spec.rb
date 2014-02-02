require 'spec_helper'
require 'support/shared_blocked_email_address_examples'

describe User do
  it_behaves_like "something with an email address"

  it { should validate_presence_of(:email) }

  it "should create a new user given valid attributes" do
    User.create!(attributes_for(:user))
  end

  context "festival subscription lookup" do
    let(:festival) { create(:festival, :with_films_and_screenings, press: true) }
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

    describe "checking visibility" do
      let(:screening) { festival.screenings.where(press: is_press).first }
      context "of normal screenings" do
        let(:is_press) { false }
        it "returns true" do
          subject.can_see?(screening).should be_true
        end
      end
      context "of press screenings" do
        let(:is_press) { true }
        it "returns false by default" do
          subject.can_see?(screening).should be_false
        end
        context "and the user does't want press screenings" do
          before { subject.stub(:subscription_for).and_return(build(:subscription, user: subject, show_press: false)) }
          it "returns false" do
            subject.can_see?(screening).should be_false
          end
        end
        context "and the user has asked for press screenings" do
          before { subject.stub(:subscription_for).and_return(build(:subscription, user: subject, show_press: true)) }
          it "returns true" do
            subject.can_see?(screening).should be_true
          end
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

  context "an unconfirmed user" do
    subject { create(:unconfirmed_user) }
    it { should_not be_mailable }
  end

  context "an unsubscribed user" do
    subject { create(:confirmed_user, preferences: { 'unsubscribed' => true }) }
    it { should_not be_mailable }
  end

  context "a bounced user" do
    subject { create(:unconfirmed_user, preferences: { 'bounced' => true }) }
    it { should_not be_mailable }

    context "who reconfirms" do
      before do
        subject.confirm!
        subject.reload
      end
      it { should be_mailable }
    end
  end

  context "preferences" do
    let(:user) { create(:confirmed_user) }

    it "should recognize a valid preference" do
      User.valid_preference?("hide_instructions").should be_true
    end

    it "should recognize an invalid preference" do
      User.valid_preference?("hack_the_server").should be_false
    end

    it "should default to nil" do
      user.hide_instructions.should be_nil
    end

    it "should also respond to ?" do
      user.hide_instructions?.should be_nil
    end

    it "should be settable" do
      user.hide_instructions = true
      user.reload.hide_instructions?.should be_true
      user.reload.hide_instructions.should be_true
      user.hide_instructions = false
      user.reload.hide_instructions?.should be_nil
      user.reload.hide_instructions.should be_nil
    end
  end

  context "determining a good festival to land on" do
    let(:user) { create(:confirmed_user) }
    let(:festival) { create(:festival, :with_films_and_screenings, slug_group: 'xyzzy') }
    let(:screening) { festival.screenings.first }
    let!(:pick) { create(:pick, user: user, festival: festival,
                         film: screening.film, screening: screening) }
    it "should pick one" do
      user.default_festival.should eq(festival)
    end
  end

  context "calendar token" do
    it "stores a token on save" do
      user = build(:user)
      user.calendar_token.should be_nil
      user.save!
      user.calendar_token.should_not be_nil
    end
  end
end
