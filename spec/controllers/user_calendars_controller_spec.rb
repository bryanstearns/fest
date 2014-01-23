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

    it "returns http success" do
      get 'show', token: user.calendar_token
      response.should be_success
    end

    it "returns the picks in ICS format" do
      CalendarFormatter.any_instance.stub(to_ics: 'output')
      get 'show', token: user.calendar_token
      response.body.should eq('output')
    end
  end
end
