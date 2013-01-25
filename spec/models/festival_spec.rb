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
      festival = build_stubbed(:festival)
      s1 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("12"))
      s2 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("13"))
      s3 = build_stubbed(:screening, film: nil, venue: nil,
                         starts_at: festival.starts_on.at("14") + 1.day)
      festival.should_receive(:screenings).and_return([s1, s2, s3])
      festival.screenings_by_date.should eq({
        festival.starts_on => [s1, s2],
        festival.starts_on + 1 => [s3],
      })
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
    festival.conflicting_screenings(festival.screenings[0])\
              .should eq([festival.screenings[1]])
  end
end
