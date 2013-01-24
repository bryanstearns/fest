require 'spec_helper'

describe Subscription do
  context 'autoscheduling' do
    subject { build(:subscription) }

    it 'initializes the autoscheduler with the right options' do
      subject.autoscheduler_options.should eq({
        user: subject.user,
        festival: subject.festival,
        show_press: subject.show_press
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
    end
  end
end
