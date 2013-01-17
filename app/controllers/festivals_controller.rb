class FestivalsController < ApplicationController
  respond_to :html
  before_filter :load_festival_and_screenings, only: [:show]
  before_filter :check_festival_access, only: [:show]
  before_filter :load_picks_for_current_user, only: [:show]

  # GET /festivals
  def index
    respond_with(@festivals = Festival.public)
  end

  # GET /festivals/1
  def show
    respond_with(@festival)
  end

protected
  def load_festival_and_screenings
    @festival = Festival.includes(screenings: [:venue, :film]).find_by_slug!(params[:id])
    @screenings = @festival.screenings
  end
end
