class UsersController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html, :json

  # GET /users
  # GET /users.json
  def index
    respond_with(@users = User.all)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_with(@user = User.find(params[:id]))
  end

  # GET /users/new
  # GET /users/new.json
  def new
    respond_with(@user = User.new)
  end

  # GET /users/1/edit
  def edit
    respond_with(@user = User.find(params[:id]))
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
    end
    respond_with(@user)
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
    end
    respond_with(@user)
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = 'User was successfully destroyed.'
    respond_with(@user)
  end
end
