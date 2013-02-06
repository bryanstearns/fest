require 'spec_helper'

describe Festival do
  context "when built" do
    subject { build(:festival) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:slug_group) }
    it { should validate_presence_of(:starts_on) }
    it { should validate_presence_of(:ends_on) }

    # it { should validate_presence_of(:revised_at) }
    # Can't do the above because we've got a before_validation on: :create
    # that defaults it. Instead, check after it's been saved.
    it "should validate presence of revised_at" do
      subject.save!
      subject.revised_at = nil
      subject.should_not be_valid
      subject.errors.should have_key(:revised_at)
    end

    it "should validate that dates are sequential" do
      subject.should be_valid
      subject.ends_on = subject.starts_on - 2
      subject.should_not be_valid
    end

    it "should set slug automatically" do
      subject.valid?
      subject.slug.should == "#{subject.slug_group}_#{subject.starts_on.strftime("%Y")}"
    end

    it "should group screenings by date in date order" do
      festival = create(:festival, :with_films_and_screenings, press: true)
      press_day = festival.starts_on - 1
      press_screenings_on_pre_day = festival.screenings.to_a.select do |s|
        s.starts_at.to_date == press_day
      end
      first_day = festival.starts_on
      non_press_screenings_on_first_day = festival.screenings.to_a.select do |s|
        s.starts_at.to_date == first_day
      end

      with_press = festival.screenings_by_date(press: true)
      with_press[press_day].should eq(press_screenings_on_pre_day)
      with_press[first_day].should eq(non_press_screenings_on_first_day)
      without_press = festival.screenings_by_date(press: false)
      without_press.should_not have_key(press_day)
      without_press[first_day].should eq(non_press_screenings_on_first_day)
    end

    it "collects picks for a given user" do
      festival = create(:festival, :with_films_and_screenings)
      pick = create(:pick, festival: festival, film: festival.films.first)
      festival.picks_for(pick.user).should == [pick]
    end

    it "collects screenings visible to a given user" do
      festival = create(:festival, :with_films_and_screenings, press: true)
      festival.screenings_visible_to(create(:user)).should == festival.screenings.where(press: false)
    end

    context 'unselecting screenings' do
      let(:festival) { create(:festival, :with_films_and_screenings) }
      let(:screenings) { festival.films.limit(2)\
                                 .map {|f| f.screenings.first }\
                                 .sort_by {|s| s.starts_at }}
      let(:user) { create(:user) }
      let!(:picks) {
        screenings.map do |s|
          create(:pick, user: user, festival: festival, screening: s)
        end
      }

      it "unselects all by default" do
        expect {
          festival.reset_screenings(user)
        }.to change {
          festival.picks_for(user).where('screening_id is not null').count
        }.by(-2)
      end
      it 'unselects just the future ones with a cutoff' do
        expect {
          festival.reset_screenings(user,
                                    screenings.first.starts_at + 1.minute)
        }.to change {
          festival.picks_for(user).where('screening_id is not null').count
        }.by(-1)
      end
    end
  end

  it "determines conflicting screenings" do
    festival = create(:festival, :with_screening_conflicts)
    user = create(:user)
    festival.conflicting_screenings(festival.screenings[0], user.id)\
              .should eq([festival.screenings[1]])
  end
end
