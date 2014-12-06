require 'spec_helper'

describe Activity do
  context "creating an activity" do
    before(:each) { Activity.disabled = false }
    let(:user) { create(:user) }
    it 'should create one' do
      expect {
        Activity.record('whee', user_id: user.id)
      }.to change(Activity, :count).by(1)
    end
    context "and an exception happens" do
      it 'should not raise' do
        allow(Activity).to receive(:create!).and_raise('boom')
        expect { Activity.record('doomed', {}) }.to_not raise_error
      end
    end
  end
end
