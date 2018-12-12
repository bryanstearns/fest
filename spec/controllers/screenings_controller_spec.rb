require 'rails_helper'

describe ScreeningsController, type: :controller do
  describe "GET 'show'" do
    it "assigns @screening, @festival, @film, and @other_screenings" do
      screening = create(:screening)
      get :show, params: {:id => screening.to_param}
      assigns(:screening).should eq(screening)
      assigns(:festival).should eq(screening.festival)
      assigns(:film).should eq(screening.film)
      assigns(:other_screenings).should eq(screening.film.screenings - [screening])
    end
  end
end
