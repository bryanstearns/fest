require 'spec_helper'

describe Cost do
  let(:festival) { create(:festival, :with_films_and_screenings, press: true,
                          starts_on: Date.today, day_count: 2) }
  let(:subscription) { create(:subscription, festival: festival, show_press: true) }
  let(:user) { subscription.user }
  let(:screening) { festival.screenings.starting_after(Time.current)\
                                       .where(press: false).find do |s|
                      festival.conflicting_screenings(s, user.id).present?
                    end }
  let(:autoscheduler) { AutoScheduler.new(festival: festival, user: user,
                                          show_press: false) }
  let(:cost) { Cost.new(autoscheduler, screening) }
  subject { cost }

  context "resetting cached costs" do
    subject do
      cost.instance_variable_set(:@total_cost, existing_cost)
      cost.reset!
      cost
    end
    context "when the existing cost is 'unpickable'" do
      let(:existing_cost) { Cost::UNPICKABLE }
      it "leaves the cost alone" do
        subject.instance_variable_get(:@total_cost).should == Cost::UNPICKABLE
      end
      it "sets the cost-as-conflict to nil" do
        subject.instance_variable_get(:@cost_as_conflict).should be_nil
      end
    end
    context "when the existing cost is not unpickable" do
      let(:existing_cost) { 23.0 }
      it "sets it to nil to force recalculation" do
        subject.instance_variable_get(:@total_cost).should be_nil
      end
      it "sets the cost-as-conflict to nil" do
        subject.instance_variable_get(:@cost_as_conflict).should be_nil
      end
    end
  end

  it "determines priority" do
    autoscheduler.stub(:film_priority).and_return(6)
    subject.priority.should == 6
  end

  it "determines started?" do
    autoscheduler.stub(:now).and_return(2.years.ago)
    subject.should_not be_started
    autoscheduler.stub(:now).and_return(2.years.from_now)
    subject.should be_started
  end

  it "determines pickable?" do
    subject.stub(:total_cost).and_return(26.2)
    subject.should be_pickable
    subject.stub(:total_cost).and_return(Cost::FREE)
    subject.should be_pickable
    subject.stub(:total_cost).and_return(Cost::UNPICKABLE)
    subject.should_not be_pickable
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

  it 'determines remaining screenings count' do
    autoscheduler.stub(:remaining_screenings_count).and_return(3)
    subject.remaining_screenings_count.should == 3
  end

  it 'determines conflicting screening costs' do
    result = double
    autoscheduler.stub(:screening_id_conflicts_costs).and_return(result)
    subject.conflicting_screening_costs.should eq(result)
  end

  describe "A picked screening" do
    let!(:pick) do
      create(:pick, user: user, festival: festival, film: screening.film,
             screening: screening)
    end
    it "has a cost of Infinity" do
      subject.total_cost.should == Cost::UNPICKABLE
    end
  end

  describe "A started screening" do
    it "has a cost of Infinity" do
      autoscheduler.stub(:now).and_return(screening.starts_at + 5.minutes)
      subject.total_cost.should == Cost::UNPICKABLE
    end
    it "has a cost-as-conflict of 0" do
      autoscheduler.stub(:now).and_return(screening.starts_at + 5.minutes)
      subject.cost_as_conflict.should == Cost::FREE
    end
  end

  describe "A screening of a 0- or unprioritized film" do
    it "has a cost of Infinity" do
      subject.stub(:priority).and_return(0)
      subject.total_cost.should == Cost::UNPICKABLE
    end
    it "has a cost-as-conflict of 0" do
      subject.stub(:priority).and_return(0)
      subject.cost_as_conflict.should == Cost::FREE
    end
  end

  describe "A screening with a picked conflict" do
    let(:screening2) { festival.conflicting_screenings(screening, user.id).first }
    let!(:conflicting_pick) do
      create(:pick, user: user, festival: festival, screening: screening2)
    end
    it "has a cost of Infinity" do
      subject.total_cost.should == Cost::UNPICKABLE
    end
    # conflicts don't influence cost_as_conflict
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
    it "has a cost of Infinity" do
      subject.total_cost.should == Cost::UNPICKABLE
    end
    it "has a cost-as-conflict of 0" do
      subject.cost_as_conflict.should == Cost::FREE
    end
  end
end
