class HomeController < ApplicationController
  before_filter :authenticate_admin!, only: [:admin]

  def index
  end

  def admin
  end

  def maintenance
    @hide_site_navigation_controls = true
  end

  def sign_ups_off
  end

  def faq
  end
end
