module Admin
  class VenuesController < ApplicationController
    before_filter :authenticate_admin!
    before_filter :load_location, only: [:new, :create]
    respond_to :html

    # GET /admin/locations/1/venues/new
    def new
      respond_with(:admin, @venue = @location.venues.build)
    end

    # GET /admin/venues/1/edit
    def edit
      respond_with(:admin, @venue = Venue.find(params[:id]))
    end

    # POST /admin/locations/1/venues
    def create
      @venue = @location.venues.build(params[:venue])
      if @venue.save
        flash[:notice] = 'Venue was successfully created.'
      end
      respond_with(:admin, @venue, location: admin_locations_path)
    end

    # PUT /admin/venues/1
    def update
      @venue = Venue.find(params[:id])
      if @venue.update_attributes(params[:venue])
        flash[:notice] = 'Venue was successfully updated.'
      end
      respond_with(:admin, @venue, location: admin_locations_path)
    end

    # DELETE /admin/venues/1
    def destroy
      @venue = Venue.find(params[:id])
      @venue.destroy
      respond_with(:admin, @venue, location: admin_locations_path)
    end

    protected
    def load_location
      @location = Location.find(params[:location_id])
    end
  end
end
