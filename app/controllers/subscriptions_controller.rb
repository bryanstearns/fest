class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :load_festival
  before_filter :load_subscription, only: [:update]
  layout 'festivals'
  respond_to :html

  # GET /festival/1/assistant
  def show
    if user_signed_in?
      load_subscription
    else
      build_temporary_subscription
    end
    @user_has_screenings = user_signed_in? &&
      current_user.has_screenings_for?(@festival)

    respond_with(@subscription)
  end

  # PUT /festivals/1/assistant
  def update
    if @subscription.update_attributes(params[:subscription])
      flash[:notice] = "This is where I would have automatically scheduled stuff."
      redirect_to festival_path(@festival)
    else
      render :show
    end
  end

protected
  def load_festival
    @festival = Festival.find(params[:festival_id])
  end

  def load_subscription
    @subscription = current_user.subscription_for(@festival, create: true)
  end

  def build_temporary_subscription
    @subscription = @festival.subscriptions.build
  end
end
