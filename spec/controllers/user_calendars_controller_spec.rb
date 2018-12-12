require 'rails_helper'

describe UserCalendarsController, type: :controller do
  describe "GET 'show'" do
    let(:festival) { create(:festival, :with_films_and_screenings) }
    let(:user) { create(:user) }
    let!(:picks) do
      festival.venues.first.screenings.each do |s|
        create(:pick, user: user, festival: festival, screening: s)
      end
    end

    before do
      allow_any_instance_of(CalendarFormatter).to receive(:to_ics).
                                                      and_return('output')
      get 'show', params: { user_id: user.id, id: user.calendar_token }
    end

    it "returns http success" do
      response.should be_success
    end

    it "returns the picks in ICS format" do
      response.body.should eq('output')
    end
  end
end
