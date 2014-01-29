require 'spec_helper'

describe UserCalendarsController do
  describe "GET 'show'" do
    let(:festival) { create(:festival, :with_films_and_screenings) }
    let(:user) { create(:user) }
    let!(:picks) do
      festival.venues.first.screenings.each do |s|
        create(:pick, user: user, festival: festival, screening: s)
      end
    end

    before do
      CalendarFormatter.any_instance.stub(to_ics: 'output')
      get 'show', user_id: user.id, id: user.calendar_token
    end

    it "returns http success" do
      response.should be_success
    end

    it "returns the picks in ICS format" do
      response.body.should eq('output')
    end
  end
end
