require 'spec_helper'

describe ApplicationHelper do
  helper ApplicationHelper
  context "current_user_is_admin?" do
    subject { helper.current_user_is_admin? }
    context "without user logged in" do
      before { helper.stub(user_signed_in?: false) }
      it { should be_false }
    end
    context "with non-admin user logged in" do
      before do
        helper.stub(user_signed_in?: true)
        helper.stub(current_user: build(:user, :admin => nil))
      end
      it { should be_false }
    end
    context "with admin user logged in" do
      before do
        helper.stub(user_signed_in?: true)
        helper.stub(current_user: build(:user, :admin => true))
      end
      it { should be_true }
    end
  end
end
