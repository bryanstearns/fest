require 'spec_helper'

describe AutoScheduler do
  let(:user) { create(:user) }
  let(:festival) { create(:festival, :with_films_and_screenings) }
  subject { AutoScheduler.new(festival: festival, user: user,
                              show_press: false) }

  it 'picks screenings until there are no more to pick' do
    subject.stub(:next_best_screening).and_return(:something, :something, nil)
    subject.expects(:schedule).twice
    subject.run
    subject.scheduled_count.should == 2
  end
end
