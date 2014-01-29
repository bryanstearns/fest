require 'spec_helper'

describe UserRatingsController do
  describe "GET 'show'" do
    let(:subscription) { create(:subscription) }
    before do
      get :show, user_id: subscription.user_id, id: subscription.ratings_token
    end

    context "assigns" do
      it "assigns the requested subscription as @subscription" do
        assigns(:subscription).should eq(subscription)
      end
      it "assigns the requested festival as @festival" do
        assigns(:festival).should eq(subscription.festival)
      end
      it "assigns the user's picks with ratings as @picks_by_rating" do
        assigns(:picks_by_rating).should \
          eq(subscription.festival.picks_for(subscription.user)\
                                  .rated.group_by(&:rating))
      end
    end

    it "returns http success" do
      response.should be_success
    end
  end
end
