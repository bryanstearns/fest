module Admin
  class LocationsController < ApplicationController
    before_filter :authenticate_admin!
    respond_to :html

    # GET /admin/locations
    def index
      respond_with(:admin, @locations = Location.order(:name).includes(:venues))
    end

    # GET /admin/locations/new
    def new
      respond_with(:admin, @location = Location.new)
    end

    # GET /admin/locations/1/edit
    def edit
      respond_with(:admin, @location = Location.find(params[:id]))
    end

    # POST /admin/locations
    def create
      @location = Location.new(params[:location])
      if @location.save
        flash[:notice] = 'Location was successfully created.'
      end
      respond_with(:admin, @location, location: admin_locations_path)
    end

    # PUT /admin/locations/1
    def update
      @location = Location.find(params[:id])
      if @location.update_attributes(params[:location])
        flash[:notice] = 'Location was successfully updated.'
      end
      respond_with(:admin, @location, location: admin_locations_path)
    end

    # DELETE /admin/locations/1
    def destroy
      @location = Location.find(params[:id])
      @location.destroy
      flash[:notice] = 'Location was successfully destroyed.'
      respond_with(:admin, @location)
    end
  end
end
