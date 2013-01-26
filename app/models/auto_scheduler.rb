class AutoScheduler
  class InternalError < StandardError; end
  attr_reader :festival, :show_press, :unselect, :user, :now
  attr_accessor :verbose

  class Cost
    UNPICKABLE = Float::INFINITY

    def initialize(autoscheduler, screening)
      @autoscheduler = autoscheduler
      @screening = screening
      @local_cost = nil
    end

    def local_cost
      @local_cost ||= begin
        UNPICKABLE
      end
    end

    def update
      return UNPICKABLE if @local_cost == UNPICKABLE
      local_cost
    end
  end

  def initialize(options)
    @user = options[:user]
    @festival = options[:festival]
    @show_press = options[:show_press]
    @unselect = options[:unselect] || 'none'
    @now = options[:now] || Time.current
  end

  def run
    unselect_screenings(unselect)
    loop do
      schedule(next_best_screening || break)
    end
  end

  def unselect_screenings(unselect)
    festival.reset_screenings(user, unselect == 'future') \
      unless unselect == 'none'
  end

  def next_best_screening
    all_screenings.each {|screening| update_screening_cost(screening) }
    find_cheapest_screening
  end

  def update_screening_cost(screening)
    costs[screening].update
  end

  def find_cheapest_screening
    cost = find_minimum_cost
    cost.screening if cost && cost.pickable?
  end

  def find_minimum_cost
    costs.values.min_by {|cost| cost.combined_cost }
  end

  def costs
    @costs ||= Hash.new do |h, screening|
      h[screening] = Cost.new(self, screening)
    end
  end

  def schedule(screening)
    check_for_conflict!(screening)

    pick = current_picks_by_film_id[screening.film_id]
    pick.screening = screening
    pick.save!
    current_picks_by_screening_id[screening.id] = pick
    current_pickable_screenings.delete(screening)
  end

  def check_for_conflict!(screening)
    raise(InternalError, "oops: scheduling against a picked screening") \
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
        puts "screening #{s.id} not pickable because film #{s.film_id} screening #{film_id_scheduled?(s.film_id)} is already scheduled" if verbose
        false
      elsif screening_id_conflicts_scheduled?(s.id)
        puts "screening #{s.id} is not pickable because conflict #{screening_id_conflicts_scheduled?(s.id)} is scheduled" if verbose
        false
      elsif s.starts_at < now
        puts "screening #{s.id} is not pickable because it started already, at #{s.starts_at}" if verbose
        false
      else
        puts "screening #{s.id} is pickable!" if verbose
        true
      end
    end.compact
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
end
