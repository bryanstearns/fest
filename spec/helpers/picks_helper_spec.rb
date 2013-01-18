require 'spec_helper'

describe PicksHelper do
  helper PicksHelper

  it 'builds a heading for a film' do
    film = mock(name: 'Vertigo')
    helper.pick_film_heading(film).should match(/Vertigo/)
  end

  describe 'DRYing up Javascript stuff' do
    it 'gives a JSONish map of pick priority to index' do
      helper.pick_priority_to_index_in_javascript.should ==
        '{0:0, 1:1, 2:2, 4:3, 8:4}'
    end
    it 'gives a JSONish map of index to pick priority' do
      helper.pick_index_to_priority_in_javascript.should ==
        '{0:0, 1:1, 2:2, 3:4, 4:8}'
    end
    it 'gives a list of priority hints' do
      helper.pick_priority_hints_in_javascript.should ==
          '["I don\'t want to see this; never schedule it for me",' +
           '"I\'d see this, but only if there\'s room in my schedule",' +
           '"I\'d see this","I want to see this",' +
           '"I *really* want to see this!"]'
    end
    it 'gives a list of rating hints' do
      helper.pick_rating_hints_in_javascript.should ==
          '["1 star: It was bad","2 stars: It wasn\'t very good",' +
           '"3 stars: It was alright","4 stars: It was good",' +
           '"5 stars: It was *really* good"]'
    end
  end

  describe "gathering pick details" do
    let(:festival) { create(:festival, :with_films_and_screenings) }
    let(:user) { create(:user) }
    let(:picked_film) { festival.films.first }
    let(:pick) { create(:pick, user: user, film: picked_film,
                        priority: 8, rating: 2) }
    it "gathers them" do
      helper.pick_details_by_film_id([pick]).should ==
        {
          picked_film.id => {
            priority: 8,
            rating: 2,
            screening_id: nil
          }
        }
    end
  end
  describe "gathering screening status details" do
    let(:festival) { create(:festival, :with_films_and_screenings) }
    let(:user) { create(:user) }
    let(:films) { festival.films.all.select { |f| f.screenings.count > 1 } }
    let(:picked_film) { films[0] }
    let(:picked_screening) { picked_film.screenings.first }
    let(:unpicked_screening) { picked_film.screenings.last }
    let(:picked_film_pick ) { create(:pick, user: user, film: picked_film,
                                     screening: picked_screening) }
    let(:unpicked_film) { festival.films.find {|f| f != picked_film } }
    let(:unpicked_film_pick ) { create(:pick, user: user, film: unpicked_film) }
    let(:picks) { [picked_film_pick, unpicked_film_pick] }
    subject { screening_ids_by_status(festival.screenings, picks) }
    it "gathers them" do
      subject.should == {
        'scheduled' => [picked_screening.id],
        'otherscheduled' => [unpicked_screening.id],
        'unranked' => festival.screenings.map(&:id) -
                        [picked_screening.id, unpicked_screening.id]
      }
    end
  end
end
