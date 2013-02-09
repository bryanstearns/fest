class ScreeningsController < ApplicationController
  respond_to :html
  layout false

  # GET /screenings/1
  def show
    @screening = Screening.includes(:festival, :film).find(params[:id])
    @festival = @screening.festival
    @film = @screening.film
    @subscription = current_user.subscription_for(@festival) if user_signed_in?
    @show_press = @subscription.try(:show_press)
    @other_screenings = @film.screenings.with_press(@show_press)\
                             .includes(:venue).to_a - [@screening]
    respond_with(@screening)
  end
end
