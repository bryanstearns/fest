class HomeController < ApplicationController
  before_filter :authenticate_admin!, only: [:admin]

  def landing
    flash.keep
    if user_signed_in?
      festival = current_user.default_festival
      if festival
        if current_user.has_screenings_for?(festival)
          redirect_to festival
        else
          redirect_to festival_priorities_path(festival)
        end
        return
      end
    end
    redirect_to welcome_path
  end

  def index
    @announcements = Announcement.published.limit(4)
                                 .order(published_at: :desc)
    current_user.news_delivered! if user_signed_in? && current_user.hasnt_seen?(@announcements.first)
  end

  def admin
  end

  def changes
  end

  def maintenance
    @hide_site_navigation_controls = true
  end

  def sign_ups_off
  end

  def help
  end
end
