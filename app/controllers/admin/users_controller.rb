module Admin
  class UsersController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/users
    # GET /admin/festivals/1/users
    def index
      @order = params[:order] if %w[name email activity].include?(params[:order])
      @users = if params[:festival_id]
        @festival = Festival.find_by_slug!(params[:festival_id])
        @festival.users
      else
        User.all
      end
      respond_with(:admin, @users)
    end

    # GET /admin/users/1
    def show
      @user = User.includes(:activity).find(params[:id])
      @activity = @user.activity
      respond_with(:admin, @user)
    end

    # POST /admin/users/1/act_as
    def act_as
      @user = User.find(params[:id])
      sign_in(:user, @user)
      flash[:notice] = "You're now acting as #{@user.name} / #{@user.email}"
      redirect_to(root_path)
    end

    # GET /admin/users/new
    def new
      respond_with(:admin, @user = User.new)
    end

    # GET /admin/users/1/edit
    def edit
      respond_with(:admin, @user = User.find(params[:id]))
    end

    # POST /admin/users
    def create
      @user = User.new(user_params)
      if @user.save
        flash[:notice] = 'User was successfully created.'
      end
      respond_with(:admin, @user)
    end

    # PATCH /admin/users/1
    def update
      @user = User.find(params[:id])
      if @user.update_attributes(user_params)
        flash[:notice] = 'User was successfully updated.'
      end
      respond_with(:admin, @user)
    end

    # DELETE /admin/users/1
    def destroy
      @user = User.find(params[:id])
      @user.destroy
      flash[:notice] = 'User was successfully destroyed.'
      respond_with(:admin, @user)
    end

  private
    def user_params
      params.require(:user).
          permit(:email, :name, :password, :password_confirmation,
                 :remember_me, :welcomed_at)
    end
  end
end
