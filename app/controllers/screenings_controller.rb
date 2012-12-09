class ScreeningsController < ApplicationController
  before_filter :authenticate_admin!
  before_filter :load_film_and_festival, only: [:index, :new, :create]
  before_filter :load_screening_film_and_festival, except: [:index, :new, :create]
  before_filter :load_venues_for_select, only: [:new, :edit]

  # GET /films/1/screenings
  # GET /films/1screenings.json
  def index
    @screenings = @film.screenings.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @screenings }
    end
  end

  # GET /screenings/1
  # GET /screenings/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @screening }
    end
  end

  # GET /films/1/screenings/new
  # GET /films/1/screenings/new.json
  def new
    @screening = @film.screenings.build(festival: @festival)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @screening }
    end
  end

  # GET /screenings/1/edit
  def edit
  end

  # POST /films/1/screenings
  # POST /films/1/screenings.json
  def create
    @screening = @film.screenings.build(params[:screening])

    respond_to do |format|
      if @screening.save
        format.html { redirect_to @film, notice: 'Screening was successfully created.' }
        format.json { render json: @screening, status: :created, location: @screening }
      else
        format.html { render action: "new" }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /screenings/1
  # PUT /screenings/1.json
  def update
    respond_to do |format|
      if @screening.update_attributes(params[:screening])
        format.html { redirect_to @film, notice: 'Screening was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @screening.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /screenings/1
  # DELETE /screenings/1.json
  def destroy
    @screening.destroy

    respond_to do |format|
      format.html { redirect_to @film }
      format.json { head :no_content }
    end
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
