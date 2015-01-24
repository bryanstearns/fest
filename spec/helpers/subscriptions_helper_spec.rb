require 'spec_helper'

describe SubscriptionsHelper, type: :helper do
  helper SubscriptionsHelper

  describe "unselect_menu_choices" do
    let(:screening) { double("screening") }
    let(:pick) { double("pick", screening: screening, auto: false) }
    subject { unselect_menu_choices([pick]) }
    context "when there are future screening picks" do
      before { allow(screening).to receive(:future?).and_return(true) }
      it { is_expected.to include(["Deselect all the future screenings", :future]) }
      context "when any are automatic" do
        before { allow(pick).to receive(:auto).and_return(true) }
        it { is_expected.to include(["Deselect just the future automatically-scheduled screenings - leave the manually-picked ones", :auto]) }
      end
      it { is_expected.to include(["Deselect all of them", :all]) }
    end
    context "when there are no future picks" do
      it { is_expected.to include(["Deselect them", :all]) }
    end
    it { is_expected.to include(["Leave them selected; just fill in around them", :none]) }
  end
end
