class HomeController < ApplicationController
  before_filter :authenticate_admin!, only: [:admin]

  def landing
    flash.keep
    if user_signed_in?
      last_pick = current_user.picks.includes(:festival).order('picks.updated_at').last
      festival = last_pick.try(:festival)
      if festival && festival == Festival.published.order(:starts_on).where(slug_group: festival.slug_group).last
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
