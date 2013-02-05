require 'spec_helper'

describe AutoScheduler do
  let(:user) { create(:user) }
  let(:festival) { create(:festival, :with_films_and_screenings,
                          starts_on: Date.tomorrow, press: true) }
  let(:now) { Time.current }
  let(:subscription) { create(:subscription, festival: festival,
                              user: user)}
  let(:autoscheduler) {
    AutoScheduler.new(festival: festival, user: user,
                      subscription: subscription,
                      show_press: false, now: now) }
  let(:expected_visible_screenings) { festival.screenings_visible_to(user) }
  let(:expected_visible_films) { expected_visible_screenings.map(&:film).uniq }

  context 'when skip_autoscheduler is set' do
    let(:subscription) { build(:subscription, skip_autoscheduler: true) }
    it 'declines to run' do
      autoscheduler.should_run?.should be_false
    end

    it 'returns a blank message' do
      autoscheduler.message.should be_blank
    end
  end

  context 'when initializing' do
    subject { autoscheduler }

    it 'loads the user\'s picks' do
      subject.current_picks.should eq(festival.picks_for(user))
    end
    it 'loads the user-visible screenings' do
      subject.all_screenings.should eq(expected_visible_screenings)
    end
    it 'makes a map of screenings by id' do
      subject.all_screenings_by_id.should eq(expected_visible_screenings.map_by(:id))
    end
    it 'makes a map of films to remaining screening count' do
      # TODO: beef up test:
      subject.all_remaining_screening_count_by_film_id.count.should ==
          subject.all_screenings.map(&:film_id).uniq.count
    end
    it 'makes a map of film_id to film' do
      subject.all_films_by_id.keys.sort.should \
        eq(expected_visible_films.map(&:id).sort)
    end

    it 'determines screening conflicts' do
      got_conflicts = subject.all_conflicting_screening_ids_by_screening_id
      got_conflicts.count.should eq(expected_visible_screenings.count)
      festival.screenings.each do |screening|
        conflicts = festival.screenings.map do |s|
          s.id if s.conflicts_with?(screening)
        end.compact
        got_conflicts[screening.id].should eq(conflicts)
      end
    end

    it 'keeps a list of pickable screenings' do
      subject.stub(:film_priority) {|id| id % 2 == 0 ? 4 : 0 }
      subject.current_pickable_screenings.should \
        eq(subject.all_screenings.select {|s| s.film_id % 2 == 0 })
    end
  end

  context 'when asked' do
    subject { autoscheduler }
    let(:screening) do
      festival.screenings.where(press: false).find do |s|
        festival.conflicting_screenings(s).present?
      end
    end
    let!(:pick) do
      create(:pick, user: user, festival: festival, film: screening.film,
             screening: screening, priority: 4)
    end
    let(:screening2) { festival.conflicting_screenings(screening)\
                                 .find {|s| !s.press } }

    it 'reports whether a film is scheduled' do
      subject.film_id_scheduled?(screening.film_id).should be_true
      subject.film_id_scheduled?(screening2.film_id).should be_false
    end

    it 'reports whether a screening is scheduled' do
      subject.screening_id_scheduled?(screening.id).should be_true
      subject.screening_id_scheduled?(screening2.id).should be_false
    end

    it 'reports whether any of a screening\'s conflicts is scheduled' do
      subject.screening_id_conflicts_scheduled?(screening2.id).should be_true
      subject.screening_id_conflicts_scheduled?(screening.id).should be_false
    end

    it 'returns a list of a screening\'s conflicts' do
      subject.screening_id_conflicts(screening.id).should == \
        subject.all_screenings.select {|s| s.conflicts_with?(screening) }
    end

    it 'returns a list of a screening\'s conflicts\' costs' do
      conflicting_screenings = [mock, mock]
      cost_first = mock
      cost_last = mock
      costs = { conflicting_screenings.first => cost_first,
                conflicting_screenings.last => cost_last }
      subject.stub(:screening_id_conflicts).and_return(conflicting_screenings)
      subject.stub(:costs).and_return(costs)
      subject.screening_id_conflicts_costs(screening.id).should ==
          [cost_first, cost_last]
    end

    it 'returns the number of remaining screenings for a film' do
      subject.stub(:all_remaining_screening_count_by_film_id).and_return(5 => 3)
      subject.remaining_screenings_count(5).should == 3
    end

    context 'for a film\'s priority' do
      describe 'when the film has a pick' do
        it 'gets the priority from the pick' do
          subject.film_priority(screening.film_id).should == 4
        end
      end
      describe 'when the film has no pick' do
        it 'gets a 0 priority' do
          subject.film_priority(screening2.film_id).should == 0
        end
      end
    end
  end

  context 'when running' do
    subject { autoscheduler }

    it 'starts by unselecting old screenings' do
      subject.stub(:next_best_screening).and_return(nil)
      festival.expects(:reset_screenings).once
      subject.run
    end

    it 'picks screenings until there are no more to pick' do
      subject.stub(:next_best_screening).and_return(mock(id: -1),
                                                    mock(id: -2),
                                                    nil)
      subject.expects(:schedule).twice
      subject.run
    end
  end

  context 'finding the cheapest screening' do
    it 'resets costs, then asks each for its cost and picks the smallest' do
      expensive = mock(total_cost: Cost::UNPICKABLE, screening_id: 0)
      middling = mock(total_cost: 5.0, screening_id: 0)
      cheapie = mock(total_cost: 1.0, screening_id: 0)
      costs = { a: expensive, b: cheapie, c: middling }
      autoscheduler.stub(:current_pickable_screenings).and_return(costs.keys)
      autoscheduler.stub(:costs).and_return(costs)
      costs.each_value {|cost| cost.should_receive(:reset!).once }
      autoscheduler.find_minimum_cost.should == cheapie
    end

    it 'returns the cheapest one if it\'s pickable' do
      screening = mock(id: 1000)
      cost = mock(:pickable? => true, :screening => screening)
      autoscheduler.stub(:find_minimum_cost).and_return(cost)
      autoscheduler.next_best_screening.should == screening
    end

    it 'returns nil if there aren\'t any' do
      autoscheduler.stub(:find_minimum_cost).and_return(nil)
      autoscheduler.next_best_screening.should be_nil
    end

    it 'returns nil if the cheapest one isn\'t pickable' do
      cost = mock(:pickable? => false)
      autoscheduler.stub(:find_minimum_cost).and_return(cost)
      autoscheduler.next_best_screening.should be_nil
    end
  end

  context 'when scheduling' do
    let(:screening) do
      festival.screenings.where(press: false).find do |s|
        festival.conflicting_screenings(s).present?
      end
    end
    let!(:existing_pick) do
      create(:pick, user: user, festival: festival, film: screening.film,
             screening: screening)
    end

    context 'a conflicting screening' do
      let(:screening2) { festival.conflicting_screenings(screening)\
                                 .find {|s| !s.press } }
      let!(:conflicting_pick) do
        create(:pick, user: user, festival: festival, film: screening2.film)
      end
      subject {
        autoscheduler.schedule(screening2)
      }
      it 'should raise' do
        expect { subject }.to raise_error(AutoScheduler::InternalError)
      end
    end

    context 'a non-conflicting screening' do
      let(:screening2) do
        festival.screenings\
                .where('press = ? and film_id <> ? and id not in (?)',
                       false,
                       screening.film_id,
                       festival.conflicting_screenings(screening).map(&:id))\
                .first.tap do |result|
          fail unless result
        end
      end
      let!(:nonconflicting_pick) do
        create(:pick, user: user, festival: festival, film: screening2.film,
               priority: 4)
      end
      subject { autoscheduler.schedule(screening2) }

      it { should_not raise_error(AutoScheduler::InternalError) }

      it 'should update the current_ lists' do
        autoscheduler.current_picks_by_screening_id.should_not have_key(screening2.id)
        autoscheduler.current_picks_by_film_id.should have_key(nonconflicting_pick.film_id)
        autoscheduler.current_picks_by_film_id[nonconflicting_pick.film_id].should == nonconflicting_pick
        autoscheduler.current_pickable_screenings.should include(screening2)
        autoscheduler.costs.should have_key(screening2)
        subject
        nonconflicting_pick.reload.screening_id.should_not be_nil
        autoscheduler.current_picks.should include(nonconflicting_pick)
        autoscheduler.current_picks_by_screening_id.should have_key(screening2.id)
        autoscheduler.current_pickable_screenings.should_not include(screening2)
      end
    end
  end
end
