class UserCalendarsController < ApplicationController
  respond_to :ics

  def show
    user = User.where(calendar_token: params[:token]).first!
    screenings = user.screenings.for_calendar
    formatter = CalendarFormatter.new(screenings)
    send_data formatter.to_ics,
              filename: formatter.filename,
              content_type: 'text/calendar'
  end
end
