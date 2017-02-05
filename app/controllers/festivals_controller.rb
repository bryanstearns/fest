class FestivalsController < ApplicationController

  include PrawnHelper

  respond_to :html
  respond_to :pdf, :xlsx, :ics, only: [:show]

  before_filter :load_festival, only: [:random_priorities, :reset_rankings, :reset_screenings]
  before_filter :load_festival_and_screenings, only: [:show]
  before_filter :check_festival_access, only: [:show]
  before_filter :check_ffff_spreadsheet_access, only: [:show]
  before_filter :load_subscription_and_picks_for_current_user, only: [:show]
  before_filter :pass_through_debug_flag, only: [:show]
  before_filter :check_for_news, only: [:show]

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
      format.ics do
        screenings = @screenings.with_press(@show_press)
        formatter = CalendarFormatter.new(@festival.name, screenings)
        if params[:raw]
          render text: formatter.to_ics, content_type: 'text/plain'
        else
          send_data formatter.to_ics,
                    filename: formatter.filename,
                    content_type: 'text/calendar'
        end
      end
    end
    response.headers['Content-Disposition'] =
      "attachment; filename=\"#{@festival.slug}_ratings.xlsx\"" \
      if request.format == Mime::Type.lookup_by_extension(:xlsx)
  end

  # PATCH /festivals/1/random_priorities
  def random_priorities
    reset_action("random_priorities")
    flash[:notice] = 'Random priorities have been set.'
    redirect_to festival_priorities_path(@festival)
  end

  # PATCH /festivals/1/reset_rankings
  def reset_rankings
    reset_action("reset_rankings")
    flash[:notice] = 'Your priorities and ratings have been reset.'
    redirect_to festival_priorities_path(@festival)
  end

  # PATCH /festivals/1/reset_screenings
  def reset_screenings
    reset_action("reset_screenings")
    flash[:notice] = 'All your screenings have been unselected.'
    redirect_to festival_path(@festival)
  end

protected
  def reset_action(action)
    return unless user_signed_in?
    @festival.send(action, current_user)
    Activity.record(name: action, festival: @festival,
                    user: current_user)
  end

  def load_festival
    @festival = Festival.find_by_slug!(params[:id])
  end

  def load_festival_and_screenings
    @festival = Festival.includes(screenings: [:venue, :film]).find_by_slug!(params[:id])
    @screenings = @festival.screenings
  end

  def check_ffff_spreadsheet_access
    raise(ActiveRecord::RecordNotFound) \
      if request.format == :xlsx && !view_context.allow_ffff_download?
  end

  def pass_through_debug_flag
    @subscription.debug = params['debug'] if @subscription && current_user_is_admin?
  end
end
