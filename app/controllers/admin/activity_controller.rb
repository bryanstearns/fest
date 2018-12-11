module Admin
  class ActivityController < ApplicationController
    before_action :authenticate_admin!
    respond_to :html

    # GET /activity
    # GET /users/1/activity
    def index
      @user = params[:user_id] && User.find(params[:user_id])
      @activity = (@user ? @user.activity : Activity).page(params[:page])
      respond_with(@activity)
    end

    # POST /activity/:id/apply
    def restore
      ActiveRecord::Base.transaction do
        activity = Activity.preload(:user).find(params[:id])
        all_or_some = activity.restore_old_screenings!
        case all_or_some
        when :all
          flash[:notice] = "Screenings restored!"
        else
          flash[:warning] = "Only some screenings were restored"
        end
        Activity.record("restore_screenings",
          user: activity.user,
          festival: activity.festival,
          subject: activity
        )
      end
      redirect_to(:back)
    rescue Activity::NoOldScreenings
      flash[:error] = "No old screenings to restore!"
      redirect_to(:back)
    end
  end
end
