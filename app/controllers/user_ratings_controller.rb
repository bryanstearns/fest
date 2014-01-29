class UserRatingsController < ApplicationController
  def show
    if !params[:user_id]
      # its the old-style URL /ratings/:token -- redirect to the
      # new style /users/:user_id/ratings/:token
      @subscription = Subscription.where(ratings_token: params[:id])\
                                  .includes(:festival, :user)\
                                  .first!
      redirect_to user_rating_path(@subscription.user, @subscription.ratings_token),
                  status: :moved_permanently
      return
    end

    @user = User.find(params[:user_id])
    @subscription = @user.subscriptions.where(ratings_token: params[:id])\
                                       .includes(:festival)\
                                       .first!
    @festival = @subscription.festival
    @picks_by_rating = @festival.picks_for(@user).rated.includes(:film)\
                                .group_by {|p| p.rating }
  end
end
