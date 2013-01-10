require 'spec_helper'

describe Pick do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:film_id) }
  it { should validate_presence_of(:festival_id) }
  it { should validate_numericality_of(:priority) }
  it { should validate_numericality_of(:rating) }
  it { should validate_numericality_of(:priority) }
  it { should ensure_inclusion_of(:priority).in_array([0,1,2,4,8]) }
  it { should ensure_inclusion_of(:rating).in_array([1,2,3,4,5]) }

  describe "deducing related models" do
    let(:film) { create(:film) }
    describe "when we know the screening" do
      let(:screening) { create(:screening, film: film )}
      it "deduces film and festival from the screening" do
        pick = Pick.new({ screening: screening }, as: :pick_creator)
        pick.should have(:no).errors_on(:film_id)
        pick.should have(:no).errors_on(:festival_id)
        pick.film.should == screening.film
        pick.festival.should == screening.festival
      end
    end
    describe "when we know the film" do
      it "deduces festival from the film" do
        pick = Pick.new({ film: film }, as: :pick_creator)
        pick.screening.should be_nil
        pick.should have(:no).errors_on(:film_id)
        pick.should have(:no).errors_on(:festival_id)
        pick.festival.should == film.festival
      end
    end
  end

  it "produces priority mappings, to & from index" do
    Pick.priority_to_index.should == { 0 => 0, 1 => 1, 2 => 2, 4 => 3, 8 => 4 }
    Pick.index_to_priority.should == { 0 => 0, 1 => 1, 2 => 2, 3 => 4, 4 => 8 }
  end
end
