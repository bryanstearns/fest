require 'spec_helper'

describe ActivityHelper do
  context "creating an activity" do
    before(:each) { Activity.disabled = false }
    let(:user) { create(:user) }
    it 'should create one' do
      expect {
        record_activity('whee', user_id: user.id)
      }.to change(Activity, :count).by(1)
    end
    context "and an exception happens" do
      it 'should not raise' do
        Activity.stub(:create!).and_raise('boom')
        expect { record_activity('doomed', {}) }.to_not raise_error
      end
    end
  end
end
