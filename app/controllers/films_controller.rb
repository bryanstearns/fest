class FilmsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_festival, only: [:index, :new, :create]
  respond_to :html, :json
  layout 'festivals_admin'

  # GET /festivals/1/films
  # GET /festivals/1/films.json
  def index
    respond_with(@films = @festival.films.includes(:screenings).all)
  end

  # GET /films/1
  # GET /films/1.json
  def show
    @film = Film.includes(:festival, screenings: :venue).find(params[:id])
    @festival = @film.festival
    respond_with(@film)
  end

  # GET /festivals/1/films/new
  # GET /festivals/1/films/new.json
  def new
    respond_with(@film = @festival.films.build)
  end

  # GET /films/1/edit
  def edit
    @film = Film.includes(:festival).find(params[:id])
    @festival = @film.festival
    respond_with(@film)
  end

  # POST /festivals/1/films
  # POST /festivals/1/films.json
  def create
    @film = @festival.films.build(params[:film])
    if @film.save
      flash[:notice] = 'Film was successfully created.'
    end
    respond_with(@film, location: festival_films_path(@festival))
  end

  # PUT /films/1
  # PUT /films/1.json
  def update
    @film = Film.includes(:festival).find(params[:id])
    @festival = @film.festival
    if @film.update_attributes(params[:film])
      flash[:notice] = 'Film was successfully updated.'
    end
    respond_with(@film, location: festival_films_path(@festival))
  end

  # DELETE /films/1
  # DELETE /films/1.json
  def destroy
    @film = Film.find(params[:id])
    @film.destroy
    flash[:notice] = 'Film was successfully destroyed.'
    respond_with(@film, location: festival_films_path(@film.festival))
  end

protected
  def load_festival
    @festival = Festival.find(params[:festival_id])
    check_festival_access
  end
end
