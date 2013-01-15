class ScreeningsController < ApplicationController
  respond_to :html
  layout false

  # GET /screenings/1
  def show
    @screening = Screening.includes(:festival, :film).find(params[:id])
    @festival = @screening.festival
    @other_screenings = @screening.film.screenings.includes(:venue)
    respond_with(@screening)
  end
end
