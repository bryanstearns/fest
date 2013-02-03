require 'spec_helper'

describe Subscription do
  subject { build(:subscription) }

  describe "checking visibility" do
    let(:festival) { create(:festival, :with_films_and_screenings,
                            press: true) }
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
        it "returns false" do
          subject.can_see?(screening).should be_false
        end
      end
      context "and the user has asked for press screenings" do
        subject { build(:subscription, show_press: true) }
        it "returns true" do
          subject.can_see?(screening).should be_true
        end
      end
    end
  end

  context 'autoscheduling' do
    it 'initializes the autoscheduler with the right options' do
      subject.autoscheduler_options.should eq({
        user: subject.user,
        festival: subject.festival,
        show_press: subject.show_press,
        unselect: nil
      })
    end

    it 'passes the options to the autoscheduler' do
      options = mock
      subject.stub(:autoscheduler_options).and_return(options)
      AutoScheduler.should_receive(:new).with(options)
      subject.autoscheduler
    end

    context 'on an existing subscription' do
      subject { create(:subscription) }
      it 'runs an autoscheduler on save' do
        autoscheduler = mock
        subject.stub(:autoscheduler).and_return(autoscheduler)
        autoscheduler.should_receive(:run).once
        subject.save!
      end
    end

    context 'when the record is first saved' do
      it 'does not run the autoscheduler' do
        AutoScheduler.any_instance.should_not_receive(:run)
        subject.save!
      end
    end

    context 'when skip_autoscheduler is set' do
      it 'does not run the autoscheduler' do
        subject.skip_autoscheduler = true
        AutoScheduler.any_instance.should_not_receive(:run)
        subject.save!
      end

      it 'returns a blank message' do
        subject.autoscheduler_message.should be_blank
      end
    end

    context 'when we do autoschedule' do
      it 'returns the autoscheduler\'s message' do
        subject.autoscheduler.stub(:message).and_return('helooo')
        subject.autoscheduler_message.should == 'helooo'
      end
    end
  end
end
