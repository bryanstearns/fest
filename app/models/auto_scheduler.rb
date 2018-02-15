class AutoScheduler
  class InternalError < StandardError; end

  include ActionView::Helpers::TextHelper
  attr_reader :festival, :now, :screenings_scheduled, :subscription,
              :user, :verbose

  delegate :skip_autoscheduler, :show_press, :unselect, :debug,
           :up_to_screening_id, to: :subscription

  def initialize(options)
    @user = options[:user]
    @festival = options[:festival]
    @subscription = options[:subscription]
    @now = options[:now] || Time.current
    @verbose = options[:verbose]

    @screenings_scheduled = 0
    log "Autoscheduler created for #{user.email} at #{festival.slug}"
  end

  def should_run?
    !skip_autoscheduler && (debug != 'none')
  end

  def run
    log "Run..."
    unselect_screenings(unselect)
    loop do
      log "Pass #{screenings_scheduled}"
      screening = next_best_screening
      if screening.nil?
        log "Stopping because we didn't find another screening"
        break
      end
      if debug_limit_screening?(screening)
        log "Stopping at screening debug limit"
        break
      end
      schedule(screening)
      if debug_limit_count?
        log "Stopping at count debug limit"
        break
      end
    end
    log "Done; #{screenings_scheduled} scheduled."
  end

  def unselect_screenings(unselect)
    log "Unselecting: #{unselect}"
    festival.reset_screenings(user, unselect)
  end

  def debug_limit_screening?(screening)
    if (screening.id.to_s == @up_to_screening_id.to_s) ||
         (debug == 'free' && costs[screening].total_cost >= -1.0)
      log "debug_limit_screening = true! (#{screening.id.inspect}, #{debug.inspect})"
      true
    else
      log "debug_limit_screening = false (#{screening.id.inspect}, #{debug.inspect})"
      false
    end
  end

  def debug_limit_count?
    debug == 'one'
  end

  def message
    return nil unless should_run?
    case screenings_scheduled
    when 0
      'No more screenings scheduled.'
    when 1
      "One screening scheduled: " +
          "#{@last_scheduled_cost.total_cost if Rails.env.development?} " +
          "#{@last_scheduled_screening.name} " +
          "on #{I18n.l @last_scheduled_screening.starts_at, format: :dmd_hm }"
    else
      "#{pluralize(screenings_scheduled, 'more screening')} scheduled."
    end.tap {|result| log "Message: \"#{result}\"" }
  end

  def next_best_screening
    cost = find_minimum_cost
    cost.screening if cost && cost.pickable?
  end

  def find_minimum_cost
    reset_costs

    pickable_costs = current_pickable_screenings.map {|s| costs[s] }
    result = if Rails.env.development?
      all_pickable = pickable_costs.sort_by do |cost|
        log("start costing #{cost.screening.id}: #{cost.screening.name}")
        tc = cost.total_cost
        log("done costing #{cost.screening.id}: #{cost.screening.name} => #{tc}")
        tc
      end
      details = all_pickable.map {|c| "#{c.screening_id}: #{c.total_cost.round(3)}"}.join(", ")
      log("#{all_pickable.count} remaining: #{details}")
      all_pickable.first
    else
      pickable_costs.min_by {|cost| cost.total_cost }
    end

    log(result ? "find_minimum_cost found #{result.screening_id}: #{result.inspect}" \
               : "find_minimum_cost: no pickable screenings")
    result
  end

  def reset_costs
    costs.each_value {|cost| cost.reset! }
  end

  def costs
    @costs ||= all_screenings.inject({}) do |h, s|
      h[s] = Cost.new(self, s)
      h
    end
  end

  def schedule(screening)
    cost = costs[screening]
    log "Scheduling: #{screening.id}, #{cost.inspect}"
    check_for_conflict!(screening)

    pick = current_picks_by_film_id[screening.film_id]
    pick.screening = screening
    pick.auto = true
    pick.save!

    current_picks_by_screening_id[screening.id] = pick
    current_picks_by_film_id[screening.film_id] = pick
    current_pickable_screenings.delete(screening)
    @last_scheduled_screening = screening
    @last_scheduled_cost = cost
    @screenings_scheduled += 1
  end

  def check_for_conflict!(screening)
    raise(InternalError, "oops: scheduling #{screening.id} against a picked screening") \
      if screening_id_conflicts_scheduled?(screening.id)
  end

  #
  # Immutable data is prefixed by all_ and doesn't change during a run
  # hashes are suffixed on what they're keyed by (generally, _by_something_id)
  # arrays don't have _by_ in the name
  def all_screenings
    @all_screenings ||= festival.screenings_visible_to(user)
  end

  def all_screenings_by_id
    @all_screenings_by_id ||= all_screenings.map_by(:id)
  end

  def all_conflicting_screening_ids_by_screening_id
    @all_conflicts_by_id ||= begin
      all_screenings.inject(Hash.new {|h, k| h[k] = []}) do |h, s|
        h[s.id] = all_screenings.map {|sx| sx.id if s.conflicts_with?(sx, user.id) }.compact
        h
      end
    end
  end

  def all_remaining_screening_count_by_film_id
    @all_remaining_screening_count_by_film_id ||= begin
      all_screenings.inject(Hash.new {|h, k| h[k] = 0}) do |h, s|
        h[s.film_id] += 1 unless s.starts_at < now
        h
      end
    end
  end

  def all_films_by_id
    @all_films_by_id ||= begin
      film_ids = all_screenings.map {|s| s.film_id }.uniq
      festival.films.find(film_ids).map_by(:id)
    end
  end

  #
  # Structures that we update as we run are prefixed by current_
  #
  def current_picks
    @current_picks ||= festival.picks_for(user)
  end

  def current_picks_by_screening_id
    @current_picks_by_screening_id ||= current_picks.map_by do |p|
      p.screening_id
    end.except(nil)
  end

  def current_picks_by_film_id
    @current_picks_by_film_id ||= begin
      current_picks.inject(Hash.new {|h, f_id| h[f_id] = build_pick(f_id) }) do |h, pick|
        h[pick.film_id] = pick
        h
      end
    end
  end

  def build_pick(film_id)
    user.picks.build(film: all_films_by_id[film_id])
  end

  def current_pickable_screenings
    @current_pickable_screenings ||= all_screenings.select do |s|
      if film_id_scheduled?(s.film_id)
        log "screening #{s.id} not pickable because film #{s.film_id} screening #{film_id_scheduled?(s.film_id)} is already scheduled"
        false
      elsif screening_id_conflicts_scheduled?(s.id)
        log "screening #{s.id} is not pickable because conflict #{screening_id_conflicts_scheduled?(s.id)} is scheduled"
        false
      elsif film_priority(s.film_id) == 0
        log "screening #{s.id} is not pickable because it's not prioritized (or 0)."
        false
      elsif s.starts_at < now
        log "screening #{s.id} is not pickable because it started already, at #{s.starts_at}"
        false
      else
        log "screening #{s.id} is pickable!"
        true
      end
    end.compact.tap {|result| "found #{pluralize(result.count, 'pickable screening')}" }
  end

  #
  # query functions
  #
  def film_id_scheduled?(film_id)
    current_picks_by_film_id[film_id].try(:screening_id)
  end

  def screening_id_scheduled?(screening_id)
    current_picks_by_screening_id.has_key?(screening_id)
  end

  def screening_id_conflicts_scheduled?(screening_id)
    all_conflicting_screening_ids_by_screening_id[screening_id].find do |s_id|
      screening_id_scheduled?(s_id) ? s_id : nil
    end
  end

  def screening_id_conflicts(screening_id)
    all_conflicting_screening_ids_by_screening_id[screening_id].map do |s_id|
      all_screenings_by_id[s_id]
    end
  end

  def screening_id_conflicts_costs(screening_id)
    screening_id_conflicts(screening_id).map {|s| costs[s] }
  end

  def remaining_screenings_count(film_id)
    all_remaining_screening_count_by_film_id[film_id]
  end

  def film_priority(film_id)
    current_picks_by_film_id[film_id].try(:priority) || 0
  end

  def log(msg)
    return if Rails.env.test?
    msg = "AS: " + msg
    Rails.logger.info(msg)
    puts msg if verbose
  end
end
