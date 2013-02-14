require 'spec_helper'

describe UserRatingsController do
  describe "GET 'show'" do
    let!(:subscription) { create(:subscription) }
    context "assigns" do
      it "assigns the requested subscription as @subscription" do
        get :show, { token: subscription.ratings_token }
        assigns(:festival).should eq(subscription.festival)
      end
      it "assigns the requested festival as @festival" do
        get :show, { token: subscription.ratings_token }
        assigns(:festival).should eq(subscription.festival)
      end
      it "assigns the user's picks with ratings as @picks_by_rating" do
        get :show, { token: subscription.ratings_token }
        assigns(:picks_by_rating).should \
          eq(subscription.festival.picks_for(subscription.user)\
                                  .rated.group_by(&:rating))
      end
    end

    it "returns http success" do
      get 'show', token: subscription.ratings_token
      response.should be_success
    end
  end
end
