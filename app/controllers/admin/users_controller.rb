module Admin
  class UsersController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/users
    def index
      respond_with(:admin, @users = User.all)
    end

    # GET /admin/users/1
    def show
      respond_with(:admin, @user = User.find(params[:id]))
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
      @user = User.new(params[:user], as: :admin)
      if @user.save
        flash[:notice] = 'User was successfully created.'
      end
      respond_with(:admin, @user)
    end

    # PUT /admin/users/1
    def update
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user], as: :admin)
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
  end
end
