
class FfffRatingsXlsx
  include Countries::Helpers

  STYLES = {
    title: {
      sz: 30,
      b: true,
      border: 1,
      alignment: { horizontal: :center }
    },
    heading: {
      sz: 18,
      b: true,
      border: 1,
      alignment: { vertical: :center,
                   horizontal: :center }
    },
    integer: {
      sz: 14,
      format_code: "#",
      alignment: { horizontal: :center }
    },
    float: {
      sz: 14,
      format_code: "#.###",
      alignment: { horizontal: :center }
    },
    film_name: {
      sz: 14,
      b: true,
      alignment: { horizontal: :left }
    }
  }

  def initialize(workbook, festival)
    @workbook = workbook
    @festival = festival
  end

  def render
    make_sheet('Alphabetical', films_by_name)
    make_sheet('By Rating', films_by_rating)
  end

  def make_sheet(name, films)
    @sheet = @workbook.add_worksheet(name: name)
    add_headings
    add_film_rows(films)
    add_summary_rows
    @sheet
  end

  def add_headings
    @sheet.add_row ["ffff AGGREGATED RATING PROJECT - PIFF #{festival_index} FEBRUARY #{festival_year}"],
                   style: style(:title)
    @sheet.merge_cells("A1:#{column_name(column_headings.count - 1)}1")

    @sheet.add_row column_headings, style: style(:heading)

    widths = [40,20,15,15,15,15,3] + ([15] * user_names.count)
    @sheet.column_widths *widths
  end

  def style(selector)
    (@styles ||= {})[selector] ||= begin
      options = STYLES[selector] ||
                raise(ArgumentError, "bad style selector: #{selector.inspect}")
      @workbook.styles.add_style options
    end
  end

  def column_headings
    static_headings + user_names
  end

  def festival_year
    @festival.starts_on.year
  end

  def festival_index
    @festival.starts_on.year - 1977
  end

  def header_row_count
    2
  end

  def static_headings
    ["Title", "Country", "IMDB\n(10-pt scale)",
     "# of\nRaters", "Average", "Std Dev", '']
  end

  def static_column_count
    @static_column_count ||= static_headings.count
  end

  def user_names
    @user_names ||= users.map do |user|
      spaced = user.name.split(/\s+/)
      if spaced.count == 1
        user.name
      else
        half_words = spaced.count / 2
        spaced[0...half_words].join(' ') + "\n" +
            spaced[half_words..-1].join(' ')
      end
    end
  end

  def user_count
    @user_count ||= users.count
  end

  def user_ids
    @user_ids ||= users.map {|user| user.id }
  end

  def add_film_rows(films)
    films.each_with_index do |film, index|
      row = @sheet.add_row film_row(film, index), style: style(:integer)
      row.cells[0].style = style(:film_name)
      row.cells[3].style = row.cells[4].style = row.cells[5].style =
          style(:float)
    end
  end

  def film_row(film, film_index)
    [ film.name, country_names(film.countries), '' ] +
      rater_formulas(film_index) + [''] +
      ratings(film)
  end

  def rater_formulas(film_index)
    range = film_row_range(film_index)
    [ "=COUNTA(#{range})",
      "=IF(COUNTA(#{range}), AVERAGE(#{range}), \"\")",
      "=IF(COUNTA(#{range}), STDEVP(#{range}), \"\")"]
  end

  def first_user_column_name
    @first_user_column_name ||= column_name(static_column_count)
  end
  def last_user_column_name
    @last_user_column_name ||= column_name(static_column_count + user_count)
  end

  def film_row_range(film_index)
    row_number = film_index + header_row_count + 1
    "#{first_user_column_name}#{row_number}:Z#{row_number}"
  end

  def first_film_row_number
    header_row_count + 1
  end

  def last_film_row_number
    @last_film_row_number ||= header_row_count + films_by_name.count
  end

  def user_column_range(user_index)
    column_name = column_name(user_index + static_column_count)
    "#{column_name}#{first_film_row_number}:#{column_name}#{last_film_row_number}"
  end

  def column_name(index)
    @letters ||= ('A'..'Z').to_a
    @letter_count = @letters.size
    result = @letters[index % @letter_count]
    result = "#{@letters[(index / @letter_count) - 1]}#{result}" \
      if index >= @letter_count
    result
  end

  def ratings(film)
    user_ids.map {|user_id| ratings_by_film_id_and_user_id[film.id][user_id] }
  end

  def add_summary_rows
    @sheet.add_row([])

    static_columns = Array.new(static_column_count, '')
    static_columns[0] = 'Total films seen:'

    row = @sheet.add_row static_columns + user_rating_counts,
                         style: style(:integer)
    row.cells[0].style = style(:film_name)
  end

  def user_rating_counts
    (0..(user_count - 1)).map do |index|
      "=COUNTA(#{user_column_range(index)})"
    end
  end

  def picks
    @picks ||= @festival.picks.rated.for_ffff_users
  end

  def users
    @users = picks.map(&:user).uniq.sort_by {|user| user.name }
  end

  def films_by_name
    @festival.films.by_name
  end

  def films_by_rating
    films_by_name.sort_by {|f| [-average_rating(f.id), f.sort_name] }
  end

  def average_rating(film_id)
   film_ratings = ratings_by_film_id_and_user_id[film_id].values
   return 0.0 if film_ratings.empty?
   film_ratings.sum / film_ratings.count.to_f
  end

  def ratings_by_film_id_and_user_id
    @ratings ||= picks.inject(Hash.new {|h, k| h[k] = {} }) do |h, pick|
      h[pick.film_id][pick.user_id] = pick.rating
      h
    end
  end
end
