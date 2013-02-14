class UserRatingsController < ApplicationController
  def show
    @subscription = Subscription.includes(:festival, :user)\
                                .where(ratings_token: params[:token]).first!
    @festival = @subscription.festival
    @user = @subscription.user
    @picks_by_rating = @festival.picks_for(@user).rated.includes(:film)\
                                .group_by {|p| p.rating }
  end
end
