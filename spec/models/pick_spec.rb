require 'spec_helper'

describe Pick do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:film_id) }
  it { should validate_presence_of(:festival_id) }
  it { should validate_numericality_of(:priority) }
  it { should validate_numericality_of(:rating) }
  it { should validate_numericality_of(:priority) }
  it { should validate_inclusion_of(:priority).in_array([0,1,2,4,8]) }
  it { should validate_inclusion_of(:rating).in_array([1,2,3,4,5]) }

  describe "deducing related models" do
    let(:film) { create(:film) }
    describe "when we know the screening" do
      let(:screening) { create(:screening, film: film )}
      it "deduces film and festival from the screening" do
        pick = Pick.new(screening: screening)
        pick.should have(:no).errors_on(:film_id)
        pick.should have(:no).errors_on(:festival_id)
        pick.film.should == screening.film
        pick.festival.should == screening.festival
      end
    end
    describe "when we know the film" do
      it "deduces festival from the film" do
        pick = Pick.new(film: film)
        pick.screening.should be_nil
        pick.should have(:no).errors_on(:film_id)
        pick.should have(:no).errors_on(:festival_id)
        pick.festival.should == film.festival
      end
    end
  end

  it "maps priority to index" do
    Pick.priority_to_index.should == { 0 => 0, 1 => 1, 2 => 2, 4 => 3, 8 => 4 }
  end

  context "dealing with conflicting stuff" do
    let(:user) { create(:user) }
    let(:festival) { create(:festival, :with_screening_conflicts) }
    let(:initially_selected_screening) { festival.screenings[0] }
    let(:another_screening) { festival.screenings[1] }
    let!(:pick) { create(:pick, user: user, festival: festival,
                         screening: initially_selected_screening,
                         auto: true) }

    it "determines conflicting picks" do
      new_pick = build(:pick, user: user, festival: festival,
                       screening: another_screening)
      new_pick.conflicting_picks.should eq([pick])
    end

    context 'when selecting a conflicting screening' do
      let(:new_pick) do
        user.picks.find_or_initialize_for(another_screening.film_id)
      end

      before { new_pick.update_attributes(screening: another_screening) }

      it "deselects conflicting screenings" do
        pick.reload.screening_id.should be_nil
      end
      it "clears the auto flag on deselected conflicting screenings" do
        pick.reload.auto.should be_false
      end
    end
  end
end
