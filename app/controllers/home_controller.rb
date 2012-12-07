class HomeController < ApplicationController
  before_filter :authenticate_admin!, only: [:admin]

  def index
  end

  def admin
  end
end
