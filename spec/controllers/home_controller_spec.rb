require 'rails_helper'

describe HomeController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_successful
    end
  end

  describe "GET 'landing'" do
    context "when not logged in" do
      logged_out
      it "redirects to the welcome page" do
        get 'landing'
        response.should redirect_to(welcome_path)
      end
    end

    context "when logged in as a user" do
      login_user
      context "with a recent festival" do
        let(:festival) { create(:festival, :with_films_and_screenings, slug_group: 'xyzzy') }
        context "with screenings scheduled" do
          let(:screening) { festival.screenings.first }
          let!(:pick) { create(:pick, user: @signed_in_user, festival: festival,
                               film: screening.film, screening: screening) }
          it "redirects to the user's festival schedule" do
            get 'landing'
            response.should redirect_to(festival_path(festival))
          end
        end
        context "with no screenings scheduled" do
          let(:screening) { festival.screenings.first }
          let!(:pick) { create(:pick, user: @signed_in_user, festival: festival,
                               film: screening.film) }
          it "redirects to the festival priorities page" do
            get 'landing'
            response.should redirect_to(festival_priorities_path(festival))
          end
        end
      end
    end
  end
end
