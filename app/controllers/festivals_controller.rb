class FestivalsController < ApplicationController
  before_filter :authenticate_admin!, except: [:index, :show]
  layout 'festivals_admin', :only => [:edit]
  respond_to :html, :json

  # GET /festivals
  # GET /festivals.json
  def index
    respond_with(@festivals = Festival.public)
  end

  # GET /festivals/1
  # GET /festivals/1.json
  def show
    @festival = Festival.find(params[:id])
    check_festival_access
    respond_with(@festival)
  end

  # GET /festivals/new
  # GET /festivals/new.json
  def new
    respond_with(@festival = Festival.new)
  end

  # GET /festivals/1/edit
  def edit
    respond_with(@festival = Festival.find(params[:id]))
  end

  # POST /festivals
  # POST /festivals.json
  def create
    @festival = Festival.new(params[:festival])
    flash[:notice] = 'Festival was successfully created.' if @festival.save
    respond_with(@festival)
  end

  # PUT /festivals/1
  # PUT /festivals/1.json
  def update
    @festival = Festival.find(params[:id])
    if @festival.update_attributes(params[:festival])
      flash[:notice] = 'Festival was successfully updated.'
    end
    respond_with(@festival)
  end

  # DELETE /festivals/1
  # DELETE /festivals/1.json
  def destroy
    @festival = Festival.find(params[:id])
    @festival.destroy
    flash[:notice] = 'Festival was successfully destroyed.'
    respond_with(@festival)
  end
end
