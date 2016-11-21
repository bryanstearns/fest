require 'rails_helper'

describe SubscriptionsHelper, type: :helper do
  helper SubscriptionsHelper

  describe "unselect_menu_choices" do
    let(:screening) { double("screening") }
    let(:pick) { double("pick", screening: screening, auto_picked?: true) }
    let(:choice_values) { unselect_menu_choices([pick]).first.map(&:last) }
    let(:selected) { unselect_menu_choices([pick]).last }
    context "when there are future screening picks" do
      before { allow(screening).to receive(:future?).and_return(true) }
      it "offers 'deselect all future'" do
        expect(choice_values).to include(:future)
      end
      it "selects 'deselect all future'" do
        expect(selected).to eq(:future)
      end

      context "when some aren't automatic" do
        before { allow(pick).to receive(:auto_picked?).and_return(false) }
        it "offers 'deselect future but leave manual'" do
          expect(choice_values).to include(:auto)
        end
        it "selects 'deselect future but leave manual'" do
          expect(selected).to eq(:auto)
        end
      end
      it "offers 'deselect all'" do
        expect(choice_values).to include(:all)
      end
    end

    context "when there are no future picks" do
      it "offers 'deselect them'" do
        expect(choice_values).to include(:all)
      end
      it "selects 'leave them'" do
        expect(selected).to eq(:none)
      end
    end
    it "offers 'leave them'" do
      expect(choice_values).to include(:none)
    end
  end
end
