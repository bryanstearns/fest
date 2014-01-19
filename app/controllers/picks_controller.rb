class PicksController < ApplicationController
  layout 'festivals'
  before_filter :authenticate_user!, only: [:create]
  before_filter :find_or_initialize_pick, only: [:create]
  before_filter :load_festival_and_screenings, only: [:index]
  before_filter :load_film_and_festival_from_pick, only: [:create]
  before_filter :check_festival_access
  before_filter :load_subscription_and_picks_for_current_user

  respond_to :html

  # GET /festivals/1/priorities
  def index
    @films = @festival.films.by_name.includes(:screenings)
    @sort_order = params[:order] \
      if PicksHelper::FILM_SORT_ORDERS.include?(params[:order])
    respond_with(@picks)
  end

  # POST /films/1/picks
  # We take a parameter for which attribute to set, and only set that one.
  def create
    attribute_name = params[:attribute]
    attribute_value = params[:pick][attribute_name]
    if @pick.new_record? && attribute_value.nil?
      saved = true # Just pretend we saved if it'd be the default anyway.
    else
      attributes_to_update = { attribute_name => attribute_value }
      attributes_to_update[:auto] = false if (attribute_name == 'screening_id' && attribute_value.present?)
      saved = @pick.update_attributes(attributes_to_update)
      Activity.record("pick_#{attribute_name}",
        user: current_user,
        festival: @festival,
        subject: @film,
        target: @pick.screening,
        attribute: attribute_name,
        attribute_value: attribute_value,
        saved: saved
      )
    end
    @screenings_to_update = if saved
      @pick.screenings_of_films_of_changed_screenings
    else
      []
    end
    render :create, status: (saved ? :created : :unprocessable_entity)
  end

protected
  def find_or_initialize_pick
    @pick = current_user.picks.find_or_initialize_for(params[:film_id])
  end

  def load_festival_and_screenings
    @festival = Festival.find_by_slug!(params[:festival_id])
    @screenings = @festival.screenings
  end

  def load_film_and_festival_from_pick
    @film = @pick.film
    @festival = @film.festival
  end
end
