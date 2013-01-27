require 'spec_helper'

describe Cost do
  let(:festival) { create(:festival, :with_films_and_screenings, press: true,
                          starts_on: Date.today, day_count: 2) }
  let(:subscription) { create(:subscription, festival: festival, show_press: true) }
  let(:user) { subscription.user }
  let(:screening) { festival.screenings.starting_after(Time.current)\
                                       .where(press: false).find do |s|
                      festival.conflicting_screenings(s).present?
                    end }
  let(:autoscheduler) { AutoScheduler.new(festival: festival, user: user,
                                          show_press: false) }
  let(:cost) { Cost.new(autoscheduler, screening) }
  subject { cost }

  context "resetting the cost" do
    subject do
      cost.instance_variable_set(:@cost, existing_cost)
      cost.reset!
      cost.instance_variable_get(:@cost)
    end
    context "when the existing cost is 'unpickable'" do
      let(:existing_cost) { Cost::UNPICKABLE }
      it "leaves the cost alone" do
        subject.should == Cost::UNPICKABLE
      end
    end
    context "when the existing cost is 0" do
      let(:existing_cost) { 0 }
      it "leaves the cost alone" do
        subject.should == 0
      end
    end
    context "when the existing cost is not unpickable or nil" do
      let(:existing_cost) { 23 }
      it "sets it to nil to force recalculation" do
        subject.should be_nil
      end
    end
  end

  it "determines started?" do
    autoscheduler.stub(:now).and_return(2.years.ago)
    subject.should_not be_started
    autoscheduler.stub(:now).and_return(2.years.from_now)
    subject.should be_started
  end

  it "determines screening_scheduled?" do
    autoscheduler.stub(:screening_id_scheduled?).and_return(true)
    subject.screening_scheduled?.should be_true
    autoscheduler.stub(:screening_id_scheduled?).and_return(false)
    subject.screening_scheduled?.should be_false
  end

  it "determines any_conflict_picked?" do
    autoscheduler.stub(:screening_id_conflicts_scheduled?).and_return(true)
    subject.any_conflict_picked?.should be_true
    autoscheduler.stub(:screening_id_conflicts_scheduled?).and_return(false)
    subject.any_conflict_picked?.should be_false
  end

  it "determines film_scheduled?" do
    autoscheduler.stub(:film_id_scheduled?).and_return(true)
    subject.film_scheduled?.should be_true
    autoscheduler.stub(:film_id_scheduled?).and_return(false)
    subject.film_scheduled?.should be_false
  end

  describe "A picked screening" do
    let!(:pick) do
      create(:pick, user: user, festival: festival, film: screening.film,
             screening: screening)
    end
    it "has a cost of Infinity" do
      subject.cost.should == Cost::UNPICKABLE
    end
  end

  describe "A started screening" do
    it "has a cost of Infinity" do
      autoscheduler.stub(:now).and_return(screening.starts_at + 5.minutes)
      subject.cost.should == Cost::UNPICKABLE
    end
  end

  describe "A screening with a picked conflict" do
    let(:screening2) { festival.conflicting_screenings(screening).first }
    let!(:conflicting_pick) do
      create(:pick, user: user, festival: festival, screening: screening2)
    end
    it "has a cost of Infinity" do
      subject.cost.should == Cost::UNPICKABLE
    end
  end

  describe "A screening of a film picked elsewhere" do
    let(:screening2) do
      create(:screening, festival: festival, venue: screening.venue,
             film: screening.film, starts_at: screening.starts_at + 1.month)
    end
    let!(:conflicting_pick) do
      create(:pick, user: user, festival: festival, film: screening2.film,
             screening: screening2)
    end
    it "has a cost of 0" do
      subject.cost.should == 0
    end
  end
end
