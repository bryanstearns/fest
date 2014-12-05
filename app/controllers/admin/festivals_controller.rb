module Admin
  class FestivalsController < ApplicationController
    before_filter :authenticate_admin!
    layout 'festivals_admin'
    respond_to :html

    # GET /admin/festivals/show
    def show
      respond_with(:admin, @festival = Festival.find_by_slug!(params[:id]))
    end

    # GET /admin/festivals/new
    def new
      respond_with(:admin, @festival = Festival.new(revised_at: Time.current))
    end

    # GET /admin/festivals/1/edit
    def edit
      respond_with(:admin, @festival = Festival.find_by_slug!(params[:id]))
    end

    # POST /admin/festivals
    def create
      @festival = Festival.new(festival_params)
      flash[:notice] = 'Festival was successfully created.' if @festival.save
      respond_with(:admin, @festival, location: festivals_path)
    end

    # PUT /admin/festivals/1
    def update
      @festival = Festival.find_by_slug!(params[:id])
      if @festival.update_attributes(festival_params)
        flash[:notice] = 'Festival was successfully updated.'
      end
      respond_with(:admin, @festival, location: festival_path(@festival))
    end

    # DELETE /admin/festivals/1
    def destroy
      @festival = Festival.find_by_slug!(params[:id])
      @festival.destroy
      flash[:notice] = 'Festival was successfully destroyed.'
      respond_with(:admin, @festival, location: festivals_path)
    end

  private
    def festival_params
      params.require(:festival).
          permit(:ends_on, :has_press, :location_ids, :main_url, :name, :place,
                 :published, :revised_at, :scheduled, :slug, :slug_group,
                 :starts_on, :updates_url, location_ids: [])
    end
  end
end
