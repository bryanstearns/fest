module PrawnHelper
  FONTS_PATH = Rails.root.join('app', 'fonts')

  class SchedulePDF
    include ApplicationHelper
    include FestivalsHelper
    include ScreeningsHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::OutputSafetyHelper

    attr_reader :pdf

    delegate :render, to: :pdf

    def initialize(options)
      @festival = options[:festival]
      @user = options[:user]
      @picks = options[:picks]
      @subscription = options[:subscription]
      @debug = options[:debug] || true
      @pdf = Prawn::Document.new(page_size: 'LETTER', page_layout: :landscape)
      setup_geometry
      setup_choices
    end

    def setup_geometry
      @font_size = 8

      pdf.font_families.update(
          "Droid" => { normal: "#{FONTS_PATH}/DroidSans.ttf",
                       bold: "#{FONTS_PATH}/DroidSans-Bold.ttf" })

      @styles = {
          plain: ["Droid", { style: :normal, size: @font_size }],
          bold: ["Droid", { style: :bold, size: @font_size }],
          gray: ["Droid", { style: :normal, size: @font_size }],
          small: ["Droid", { style: :normal, size: @font_size * 0.85 }],
          smallbold: ["Droid", { style: :bold, size: @font_size * 0.85 }],
          h1: ["Droid", { style: :bold, size: @font_size * 1.3 }],
          h2: ["Droid", { style: :bold, size: @font_size * 1.1 }],
          h3: ["Droid", { style: :bold, size: @font_size * 1.0 }]
      }

      @small_baseline_offset = font(:plain).ascender - font(:small).ascender

      @header_height = 25
      @footer_height = 0
      @column_count = 4
      @column_gutter = 4
      @column_width = (pdf.margin_box.width -
          (@column_gutter * (@column_count - 1))) / @column_count
      @column_height = pdf.margin_box.height - (@header_height + @footer_height)
      @column_index = -1
      @page_index = 0
      @image_width = 40
      @indent = 5

      @day_name_width = @column_width * 0.56
      @day_time_width = @column_width - @day_name_width

      pdf.repeat(:all) do
        draw_header
      end

      @column_index = @column_count - 1
      next_column
    end

    def setup_choices
      @film_id_to_screening_id = {}
      @film_id_to_priority = {}
      @film_id_to_rating = {}

      @picks.each do |p|
        @film_id_to_screening_id[p.film_id] = p.screening_id if p.screening_id
        @film_id_to_priority[p.film_id] = p.priority if p.priority
        @film_id_to_rating[p.film_id] = p.rating if p.rating
      end
    end

    def render
      draw_days
      draw_films
      pdf.render
    end

    def draw_days
      days(@festival, press: show_press).each {|day| draw_day(day) }
    end

    def draw_day(day)
      return unless day.screenings.present?
      next_column unless have_room_for? \
        (font_height(:plain) * [2, day.screenings.size].min) + font_height(:h2) + 2

      day.screenings.each_with_index do |screening, index|
        force_new_column = !have_room_for?(font_height(:plain))
        next_column if force_new_column
        draw_day_header(day, index != 0) if force_new_column || index == 0
        draw_screening(screening)
      end
    end

    def draw_screening(screening)
      font(:small) do
        pdf.text_box "#{screening_times(screening)} #{screening.venue_abbreviation}",
                     :at => [@left, @y - @small_baseline_offset],
                     :width => @day_time_width, :height => pdf.font.height
      end

      font(*name_style(screening)) do
        pdf.text_box screening.short_name,
                     :at => [@left + @day_time_width, @y], :overflow => :ellipses,
                     :width => @day_name_width, :height => pdf.font.height
        @y -= pdf.font.height
      end
    end

    def name_style(screening)
      if @film_id_to_screening_id[screening.film_id] == screening.id
        [:bold]
      else
        [:plain]
      end
    end

    def have_room_for?(height)
      height <= (@y - @footer_height)
    end

    def draw_day_header(day, continued)
      @y -= 2
      font(:h3) do
        header = I18n.l day.date, format: :dmd
        header += " (cont'd)" if continued
        pdf.text_box header, :at => [@left, @y],
                     :width => @column_width, :height => pdf.font.height
        @y -= pdf.font.height + 1
      end

      #with_color("aaaaaa") do
      #  pdf.horizontal_line(@left, @left + @column_width, :at => @y)
      #  @y -= 2
      #end
    end

    def draw_films
      return unless @festival.films.present?
      films = @festival.films.by_name
      next_column(:widow) unless have_room_for? \
        font_height(:h3) + 4 + font_height(:plain) +
        ((films.first.screenings.size + 1) * font_height(:small))

      films.each_with_index do |film, index|
        screenings_count = film.screenings.size
        force_new_column = !have_room_for?(font_height(:plain) +
             font_height(:small) + (screenings_count * font_height(:small)))
        next_column if force_new_column
        draw_films_header(index != 0) if force_new_column || index == 0

        draw_film(film)
      end
    end

    def draw_film(film)
      font(:bold) do
        pdf.text_box film.short_name,
                     :at => [@left, @y], :overflow => :ellipses,
                     :width => @column_width, :height => pdf.font.height
        @y -= pdf.font.height
      end

      #font(:small) do
      #  rating = @film_id_to_rating[film.id]
      #  if rating
      #    x = @left
      #    rating.times do
      #      pdf.image "public/images/priority/star.png",
      #                :at => [x, @y+1], :height => pdf.font.height
      #      x += 7
      #    end
      #    iw = @image_width
      #  else
      #    priority = @film_id_to_priority[film.id]
      #    if priority
      #      pdf.image "public/images/priority/p#{priority}.png",
      #                :at => [@left, @y], :height => pdf.font.height * 0.8
      #      iw = @image_width
      #    else
      #      iw = 0
      #    end
      #  end
      #
      #  countries = film.country_names
      #  countries = ", #{countries}" unless countries.blank?
      #  pdf.text_box "#{film.duration / 1.minute} minutes, #{countries}",
      #               :at => [@left + iw, @y],
      #               :width => column_width - iw, :height => pdf.font.height
      #  @y -= pdf.font.height
      #end

      film.screenings.with_press(show_press).each do |screening|
        font(*time_style(screening)) do
          text = I18n.l(screening.starts_at, format: :md_hm) + ' ' +
                 screening.venue_abbreviation
          text += ' (press)' if screening.press?
          pdf.text_box text,
                       :at => [@left + @indent, @y],
                       :width => @column_width - @indent, :height => pdf.font.height
          @y -= pdf.font.height
        end
      end
    end

    def time_style(screening)
      if @film_id_to_screening_id[screening.film_id] == screening.id
        [:smallbold]
      else
        [:small]
      end
    end

    def draw_films_header(continued)
      font(:h3) do
        heading = "Film Index"
        heading += " (cont'd)" if continued
        pdf.text_box heading,
                     :at => [@left, @y],
                     :width => @column_width, :height => pdf.font.height
        @y -= pdf.font.height + 1
      end
      with_color("aaaaaa") do
        pdf.horizontal_line(@left, @left + @column_width, :at => @y)
        @y -= 2
      end
    end

    def show_press
      @subscription.try(:show_press)
    end

    def draw_header
      @y = pdf.margin_box.top
      font(:h1) do
        prefix = "#{@user.name} is a " if @user
        pdf.text "#{prefix}Festival Fanatic!", align: :left
        pdf.move_up pdf.font.height
        pdf.text @festival.name, align: :right
      end
      hr("aaaaaa")

      font(:small) do
        pdf.move_down(2)
        pdf.text "https://festivalfanatic.com/", align: :left
        pdf.move_up pdf.font.height
        pdf.text revision_info, align: :right
      end
    end

    def start_page
      pdf.start_new_page unless @page_index == 0
      @page_index += 1

      with_color("00ffff") { pdf.stroke_bounds } if @debug
    end

    def next_column
      @column_index += 1
      if @column_index == @column_count
        start_page
        @column_index = 0
      end
      @y = @footer_height + @column_height
      @left = @column_index * (@column_width + @column_gutter)
      @right = @left + @column_width
    end

    def with_color(color)
      old_fill_color = pdf.fill_color
      old_stroke_color = pdf.stroke_color
      if color
        pdf.fill_color = pdf.stroke_color = color
      end
      yield
      pdf.stroke_color = old_stroke_color
      pdf.fill_color = old_fill_color
    end

    def font(style, color=nil)
      f = pdf.font(*@styles[style]) if style
      if block_given?
        with_color(color) do
          yield
        end
      else
        f
      end
    end

    def font_height(style)
      (@heights ||= {})[style] ||= font(style).height
    end

    def hr(color)
      with_color(color) { pdf.horizontal_rule }
    end

    def text(msg, options={})
      font(options[:style]) do
        x = options.delete(:x) || 0
        y = options.delete(:y) || pdf.y
        width = options.delete(:width) || (pdf.bounds.right - x)
        height = options.delete(:height) || pdf.font.height
        pdf.text_box msg, options.merge(:overflow => :ellipses,
                                        :at => [x, y + pdf.font.ascender],
                                        :width => width, :height => height)
      end
    end

    def revision_info
      @revision_info ||= festival_revision_info(@festival, @picks)
    end
  end
end
