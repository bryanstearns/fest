class LocationsController < ApplicationController
  before_filter :authenticate_admin!
  respond_to :html, :json

  # GET /locations
  # GET /locations.json
  def index
    respond_with(@locations = Location.order(:name).includes(:venues))
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    respond_with(@location = Location.new)
  end

  # GET /locations/1/edit
  def edit
    respond_with(@location = Location.find(params[:id]))
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(params[:location])
    if @location.save
      flash[:notice] = 'Location was successfully created.'
    end
    respond_with(@location, location: locations_path)
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = 'Location was successfully updated.'
    end
    respond_with(@location, location: locations_path)
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    flash[:notice] = 'Location was successfully destroyed.'
    respond_with(@location)
  end
end
