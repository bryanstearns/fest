module Admin
  class ActivityController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /activity
    # GET /users/1/activity
    def index
      @user = params[:user_id] && User.find(params[:user_id])
      @activity = (@user ? @user.activity : Activity).page(params[:page])
      respond_with(@activity)
    end
  end
end
