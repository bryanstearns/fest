class AutoScheduler
  class InternalError < StandardError; end

  include ActionView::Helpers::TextHelper
  attr_reader :debug, :festival, :now, :show_press, :unselect, :user, :verbose,
              :screenings_scheduled

  def initialize(options)
    @user = options[:user]
    @festival = options[:festival]
    @show_press = options[:show_press]
    @unselect = options[:unselect] || 'none'
    @debug = options[:debug]
    @now = options[:now] || Time.current
    @up_to_screening_id = options[:up_to_screening_id]

    @screenings_scheduled = 0
    @verbose = options[:verbose]
    log "Autoscheduler created for #{user.email} at #{festival.slug}"
  end

  def run
    log "Run..."
    unselect_screenings(unselect)
    loop do
      log "Pass #{screenings_scheduled}"
      screening = next_best_screening
      break if screening.nil? || debug_limit_screening?(screening)
      schedule(screening)
      break if debug_limit_count?
    end
    log "Done; #{screenings_scheduled} scheduled."
  end

  def unselect_screenings(unselect)
    festival.reset_screenings(user, unselect == 'future') \
      unless unselect == 'none'
  end

  def debug_limit_screening?(screening)
    (screening.id.to_s == @up_to_screening_id.to_s) ||
      (debug == 'free' && costs[screening].total_cost >= -1.0)
  end

  def debug_limit_count?
    debug == 'one'
  end

  def message
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
    log "looking for minimum-cost screening; #{current_pickable_screenings.count} left"
    reset_costs
    costs.values.min_by {|cost| cost.total_cost }
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
    pick.save!
    current_picks_by_screening_id[screening.id] = pick
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
    @all_conflicts_by_id ||= all_screenings.inject(Hash.new {|h, k| h[k] = []}) do |h, s|
      h[s.id] = all_screenings.map {|sx| sx.id if s.conflicts_with?(sx) }.compact
      h
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
      current_picks.map_by do |p|
        p.film_id
      end
    end
  end

  def current_pickable_screenings
    @current_pickable_screenings ||= all_screenings.select do |s|
      if film_id_scheduled?(s.film_id)
        log "screening #{s.id} not pickable because film #{s.film_id} screening #{film_id_scheduled?(s.film_id)} is already scheduled"
        false
      elsif screening_id_conflicts_scheduled?(s.id)
        log "screening #{s.id} is not pickable because conflict #{screening_id_conflicts_scheduled?(s.id)} is scheduled"
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

  def log(msg)
    msg = "AS: " + msg
    Rails.logger.info(msg)
    puts msg if verbose
  end
end
