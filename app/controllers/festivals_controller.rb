class FestivalsController < ApplicationController
  respond_to :html

  # GET /festivals
  def index
    respond_with(@festivals = Festival.public)
  end

  # GET /festivals/1
  def show
    @festival = Festival.includes(screenings: [:venue, :film]).find(params[:id])
    check_festival_access
    respond_with(@festival)
  end
end
