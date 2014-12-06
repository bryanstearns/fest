require 'spec_helper'

describe Festival do
  context "when built" do
    subject { build(:festival) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:place) }
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

    context "grouping screenings" do
      let(:festival) { create(:festival, :with_films_and_screenings, press: true) }
      let(:press_day) { festival.starts_on - 1 }
      let(:first_day) { festival.starts_on }
      let(:press_screenings_on_pre_day) do
        festival.screenings.to_a.select do |s|
          s.starts_at.to_date == press_day
        end
      end
      let(:non_press_screenings_on_first_day) do
        festival.screenings.to_a.select do |s|
          s.starts_at.to_date == first_day
        end
      end

      context "with press screenings" do
        let(:screenings) { festival.screenings_by_date(press: true) }
        it "should find the press day screenings" do
          screenings[press_day].should eq(press_screenings_on_pre_day)
        end
        it "should find the first-day screenings" do
          screenings[first_day].should eq(non_press_screenings_on_first_day)
        end
      end

      context "without press screenings" do
        let(:screenings) { festival.screenings_by_date(press: false) }
        it "should find the first-day screenings" do
          screenings[first_day].should eq(non_press_screenings_on_first_day)
        end

        it "should not include press screenings" do
          screenings.should_not have_key(press_day)
        end
      end
    end

    it "collects picks for a given user" do
      festival = create(:festival, :with_films_and_screenings)
      pick = create(:pick, festival: festival, film: festival.films.first)
      festival.picks_for(pick.user).should == [pick]
    end

    it "collects screenings picked by a given user" do
      festival = create(:festival, :with_films_and_screenings)
      screening = festival.screenings.first
      pick = create(:pick, festival: festival, film: festival.films.first, screening: screening)
      festival.screenings_for(pick.user).should == [screening]
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
      let!(:picks) do
        screenings.map do |s|
          create(:pick, user: user, festival: festival, screening: s,
                 auto: (s == screenings.first))
        end
      end

      before(:each) do
        allow(Time).to receive(:current).
                           and_return(screenings.first.starts_at + 1.minute)
      end

      it "unselects all by default" do
        festival.picks_for(user).where('screening_id is not null').\
          should have_at_least(1).item

        festival.reset_screenings(user)

        festival.picks_for(user).where('screening_id is not null').\
          should have(0).items
      end

      it 'unselects just the future ones with a cutoff' do
        expect {
          festival.reset_screenings(user, 'future')
        }.to change {
          festival.picks_for(user).where('screening_id is not null').count
        }.by(-1)
      end

      it 'can skip manual picks' do
        expect {
          festival.reset_screenings(user, 'auto')
        }.to change {
          festival.picks_for(user).where('screening_id is not null').count
        }.by(0)
      end
    end

    it 'random-prioritizes films' do
      festival = create(:festival, :with_films_and_screenings)
      user = create(:user)

      festival.random_priorities(user)
      film_count = festival.films.count * 1.0
      prioritized_count = festival.picks_for(user).where('priority is not null').count
      expect(prioritized_count / film_count).to be > 0.73
    end
  end

  it "determines conflicting screenings" do
    festival = create(:festival, :with_screening_conflicts)
    user = create(:user)
    festival.conflicting_screenings(festival.screenings[0], user.id)\
              .should eq([festival.screenings[1]])
  end
end
