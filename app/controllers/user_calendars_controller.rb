class UserCalendarsController < ApplicationController
  respond_to :ics

  def show
    user = User.where(id: params[:user_id], calendar_token: params[:id]).first!
    screenings = user.screenings.for_calendar
    formatter = CalendarFormatter.new(user.name, screenings)
    if params[:raw]
      render text: formatter.to_ics, content_type: 'text/plain'
    else
      send_data formatter.to_ics,
                filename: formatter.filename,
                content_type: 'text/calendar'
    end
  end
end
