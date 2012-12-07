class FilmsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_festival, only: [:index, :new, :create]
  layout 'festivals_admin'

  # GET /festivals/1/films
  # GET /festivals/1/films.json
  def index
    @films = @festival.films.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @films }
    end
  end

  # GET /films/1
  # GET /films/1.json
  def show
    @film = Film.includes(:festival).find(params[:id])
    @festival = @film.festival

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @film }
    end
  end

  # GET /festivals/1/films/new
  # GET /festivals/1/films/new.json
  def new
    @film = @festival.films.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @film }
    end
  end

  # GET /films/1/edit
  def edit
    @film = Film.includes(:festival).find(params[:id])
    @festival = @film.festival
  end

  # POST /festivals/1/films
  # POST /festivals/1/films.json
  def create
    @film = @festival.films.build(params[:film])

    respond_to do |format|
      if @film.save
        format.html { redirect_to festival_films_path(@festival), notice: 'Film was successfully created.' }
        format.json { render json: @film, status: :created, location: @film }
      else
        format.html { render action: "new" }
        format.json { render json: @film.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /films/1
  # PUT /films/1.json
  def update
    @film = Film.includes(:festival).find(params[:id])
    @festival = @film.festival

    respond_to do |format|
      if @film.update_attributes(params[:film])
        format.html { redirect_to festival_films_path(@film.festival), notice: 'Film was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @film.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /films/1
  # DELETE /films/1.json
  def destroy
    @film = Film.find(params[:id])
    @film.destroy

    respond_to do |format|
      format.html { redirect_to festival_films_path(@film.festival) }
      format.json { head :no_content }
    end
  end

protected
  def load_festival
    @festival = Festival.find(params[:festival_id])
  end
end
