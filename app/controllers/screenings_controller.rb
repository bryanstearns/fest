class ScreeningsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_film_and_festival, only: [:index, :new, :create]
  before_filter :load_screening_film_and_festival, except: [:index, :new, :create]
  before_filter :load_venues_for_select, only: [:new, :edit]
  respond_to :html, :json

  # GET /films/1/screenings
  # GET /films/1screenings.json
  def index
    respond_with(@screenings = @film.screenings.all)
  end

  # GET /screenings/1
  # GET /screenings/1.json
  def show
    respond_with(@screening)
  end

  # GET /films/1/screenings/new
  # GET /films/1/screenings/new.json
  def new
    respond_with(@screening = @film.screenings.build(festival: @festival))
  end

  # GET /screenings/1/edit
  def edit
    respond_with(@screening)
  end

  # POST /films/1/screenings
  # POST /films/1/screenings.json
  def create
    @screening = @film.screenings.build(params[:screening])
    if @screening.save
      flash[:notice] = 'Screening was successfully created.'
    end
    respond_with(@screening, location: @film)
  end

  # PUT /screenings/1
  # PUT /screenings/1.json
  def update
    if @screening.update_attributes(params[:screening])
      flash[:notice] = 'Screening was successfully updated.'
    end
    respond_with(@screening, location: @film)
  end

  # DELETE /screenings/1
  # DELETE /screenings/1.json
  def destroy
    @screening.destroy
    flash[:notice] = 'Screening was successfully destroyed.'
    respond_with(@screening, location: @film)
  end

protected
  def load_film_and_festival
    @film = Film.includes(:festival).find(params[:film_id])
    @festival = @film.festival
  end

  def load_screening_film_and_festival
    @screening = Screening.includes(film: :festival).find(params[:id])
    @film = @screening.film
    @festival = @film.festival
  end

  def load_venues_for_select
    @venues = @festival.venues
  end
end
