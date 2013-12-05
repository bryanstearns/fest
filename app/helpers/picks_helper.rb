module PicksHelper
  FILM_SORT_ORDERS = %w[name country page priority rating screening]
  USER_SPECIFIC_SORT_ORDERS = %w[priority rating screening]

  def sort_order_is_not_user_specific?(sort_order)
    !USER_SPECIFIC_SORT_ORDERS.include?(sort_order)
  end

  def film_sort_links(films, selected=nil)
    selected ||= 'name'
    sort_options = FILM_SORT_ORDERS
    sort_options -= USER_SPECIFIC_SORT_ORDERS unless user_signed_in?
    sort_options.delete('page') \
      unless (films.any? {|f| f.page.present? } || selected == 'page')
    sort_options.map do |p|
      args = {}
      args[:order] = p unless p == 'name'
      link_to_unless(p == selected, p.titleize, festival_priorities_path(@festival, args), 'data-no-turbolink' => true)
    end.join(' | ').html_safe
  end

  def films_sorted(films, options)
    ordering = options[:by] || 'name'

    picks = begin
      raise(ArgumentError, "No picks to sort by!") \
        unless options[:picks]
      options[:picks].map_by{|p| p.film_id }
    end if %w[priority rating screening].include? ordering

    case ordering
      when 'country'
        films.sort_by {|f| [f.countries.present? ? country_names(f.countries) : 'ZZZZZZZ',
                            f.sort_name] }
      when 'page'
        films.sort_by {|f| [ f.page || 9999999.0, f.sort_name ] }
      when 'priority'
        films.sort_by {|f| [-1 * (picks[f.id].try(:priority) || -1), f.sort_name ] }
      when 'rating'
        films.sort_by {|f| [-1 * (picks[f.id].try(:rating) || -1), f.sort_name ] }
      when 'screening'
        far_future = 10.years.from_now
        films.sort_by {|f| [picks[f.id].try(:screening).try(:starts_at) || far_future,
                            f.sort_name ] }
      else
        films # we get them ordered by sort_name by default
    end
  end

  def pick_priority_to_index_in_javascript
    # TIL: JSON keys have to be strings, but we want real numeric Javascript
    # dictionaries.
    "{#{Pick::priority_to_index.map {|k,v| "#{k}:#{v}"}.join(", ")}}"
  end
  def pick_index_to_priority_in_javascript
    # Note: we're emitting v -> k, not k -> v
    "{#{Pick::priority_to_index.map {|k,v| "#{v}:#{k}"}.join(", ")}}"
  end

  def pick_priority_hints_in_javascript
    Pick::PRIORITY_HINTS.values.to_json
  end

  def pick_rating_hints_in_javascript
    Pick::RATING_HINTS.values.to_json
  end

  def pick_details_by_film_id(picks)
    picks.inject({}) do |h, pick|
      h[pick.film_id] = {
        priority: pick.priority,
        rating: pick.rating,
        screening_id: pick.screening_id
      }
      h
    end
  end

  def screening_ids_by_status(screenings, picks)
    raise ArgumentError unless screenings && picks
    picks_by_film_id = picks.map_by(:film_id)
    screenings.inject(Hash.new {|h, k| h[k] = []}) do |h, screening|
      pick = picks_by_film_id[screening.film_id]
      status = if pick
        if pick.screening_id == screening.id
          "scheduled"
        elsif pick.screening_id
          "otherscheduled"
        elsif pick.priority.nil?
          "unranked"
        elsif pick.priority > 0
          "unscheduled"
        else
          "lowpriority"
        end
      else
        "unranked"
      end
      h[status] << screening.id
      h
    end
  end
end
