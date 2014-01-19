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
    @user_picks = user_signed_in? && @festival.picks_for(current_user).includes(:screening)

    respond_with(@subscription)
  end

  # PUT /festivals/1/assistant
  def update
    if @subscription.update_attributes(params[:subscription])
      maybe_run_autoscheduler
      redirect_to festival_path(@festival)
    else
      render :show
    end
  end

protected
  def maybe_run_autoscheduler
    autoscheduler = AutoScheduler.new(user: current_user,
                                      festival: @festival,
                                      subscription: @subscription)
    if autoscheduler.should_run?
      autoscheduler.run
      Activity.record(:autoscheduled, user: current_user, festival: @festival,
                      message: autoscheduler.message)
      flash[:notice] = autoscheduler.message if autoscheduler.message.present?
    end
  end

  def load_subscription
    @subscription = current_user.subscription_for(@festival, create: true)
  end

  def build_temporary_subscription
    @subscription = @festival.subscriptions.build
  end
end
