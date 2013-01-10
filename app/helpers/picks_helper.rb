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
    "{#{Pick::priority_to_index.map {|k,v| "#{k}:#{v}"}.join(", ")}}"
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
end
