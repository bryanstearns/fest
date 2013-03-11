class FestivalsController < ApplicationController

  include PrawnHelper

  respond_to :html
  respond_to :pdf, only: [:show]

  before_filter :load_festival, only: [:reset_rankings, :reset_screenings]
  before_filter :load_festival_and_screenings, only: [:show]
  before_filter :check_festival_access, only: [:show]
  before_filter :load_subscription_and_picks_for_current_user, only: [:show]

  # GET /festivals
  def index
    @festivals = current_user_is_admin? ? Festival.all : Festival.published
    respond_with(@festivals)
  end

  # GET /festivals/1
  def show
    respond_with(@festival) do |format|
      format.pdf do
        pdf = SchedulePDF.new(festival: @festival, picks: @picks,
                              subscription: @subscription, user: current_user)
        send_data(pdf.render, filename: "#{@festival.slug}.pdf",
                  type: "application/pdf")
      end
    end
  end

  # PUT /festivals/1/reset_rankings
  def reset_rankings
    @festival.reset_rankings(current_user) if user_signed_in?
    flash[:notice] = 'Your priorities and ratings have been reset.'
    redirect_to festival_priorities_path(@festival)
  end

  # PUT /festivals/1/reset_screenings
  def reset_screenings
    @festival.reset_screenings(current_user) if user_signed_in?
    flash[:notice] = 'All your screenings have been unselected.'
    redirect_to festival_path(@festival)
  end

protected
  def load_festival
    @festival = Festival.find_by_slug!(params[:id])
  end

  def load_festival_and_screenings
    @festival = Festival.includes(screenings: [:venue, :film]).find_by_slug!(params[:id])
    @screenings = @festival.screenings
  end
end
