class ScreeningsController < ApplicationController
  respond_to :html
  layout false

  # GET /screenings/1
  def show
    @screening = Screening.includes(:festival, :film).find(params[:id])
    @festival = @screening.festival
    @film = @screening.film
    @other_screenings = @film.screenings.includes(:venue).to_a - [@screening]
    respond_with(@screening)
  end
end
