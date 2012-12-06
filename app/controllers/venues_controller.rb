class VenuesController < ApplicationController
  before_filter :load_location, only: [:new, :create]

  # GET /locations/1/venues/new
  # GET /locations/1venues/new.json
  def new
    @venue = @location.venues.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @venue = Venue.find(params[:id])
  end

  # POST /venues
  # POST /venues.json
  def create
    @venue = @location.venues.build(params[:venue])

    respond_to do |format|
      if @venue.save
        format.html { redirect_to locations_path, notice: 'Venue was successfully created.' }
        format.json { render json: @venue, status: :created, location: @venue }
      else
        format.html { render action: "new" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.json
  def update
    @venue = Venue.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to locations_path, notice: 'Venue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @venue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.json
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to locations_path, notice: 'Venue was successfully destroyed.'  }
      format.json { head :no_content }
    end
  end

protected
  def load_location
    @location = Location.find(params[:location_id])
  end
end
