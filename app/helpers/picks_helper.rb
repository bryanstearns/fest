module PicksHelper
  def pick_film_heading(film)
    film.name
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
