class PicksController < ApplicationController
  layout 'festivals'
  before_filter :authenticate_user!, only: [:create]
  before_filter :find_or_build_pick, only: [:create]
  before_filter :load_festival_and_screenings, only: [:index]
  before_filter :load_film_and_festival_from_pick, only: [:create]
  before_filter :check_festival_access
  before_filter :load_picks_for_current_user, only: [:index]

  respond_to :html

  # GET /festivals/1/priorities
  def index
    @films = @festival.films.by_name.includes(:screenings)
    respond_with(@picks)
  end

  # POST /films/1/picks
  # We take a parameter for which attribute to set, and only set that one.
  def create
    attribute_name = params[:attribute]
    attribute_value = params[:pick][attribute_name]
    saved = if @pick.new_record? && attribute_value.nil?
      true # Just pretend we saved if it'd be the default anyway.
    else
      params[:pick] = { attribute_name => attribute_value }
      @pick.update_attributes(params[:pick])
    end

    render text: "", status: (saved ? :created : :unprocessable_entity)
  end

protected
  def find_or_build_pick
    @pick = current_user.picks.includes(film: :festival)\
                              .where(film_id: params[:film_id]).first ||
            current_user.picks.build({ film_id: params[:film_id] },
                                     as: :pick_creator)
  end

  def load_festival_and_screenings
    @festival = Festival.find(params[:festival_id])
    @screenings = @festival.screenings
  end

  def load_film_and_festival_from_pick
    @film = @pick.film
    @festival = @film.festival
  end
end
