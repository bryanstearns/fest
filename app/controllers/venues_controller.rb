class VenuesController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_location, only: [:new, :create]
  respond_to :html, :json

  # GET /locations/1/venues/new
  # GET /locations/1venues/new.json
  def new
    respond_with(@venue = @location.venues.build)
  end

  # GET /venues/1/edit
  def edit
    respond_with(@venue = Venue.find(params[:id]))
  end

  # POST /locations/1/venues
  # POST /locations/1/venues.json
  def create
    @venue = @location.venues.build(params[:venue])
    if @venue.save
      flash[:notice] = 'Venue was successfully created.'
    end
    respond_with(@venue, location: locations_path)
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    @venue = Venue.find(params[:id])
    if @venue.update_attributes(params[:venue])
      flash[:notice] = 'Venue was successfully updated.'
    end
    respond_with(@venue, location: locations_path)
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy
    respond_with(@venue, location: locations_path)
  end

protected
  def load_location
    @location = Location.find(params[:location_id])
  end
end
