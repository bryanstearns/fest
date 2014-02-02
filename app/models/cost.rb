class Cost
  UNPICKABLE = Float::INFINITY
  FREE = 0.0

  attr_reader :autoscheduler, :screening

  delegate :now, to: :autoscheduler
  delegate :started?, :press?, to: :screening

  def initialize(autoscheduler, screening)
    @autoscheduler = autoscheduler
    @screening = screening
    @total_cost = @total_conflict_cost = @cost_as_conflict = nil
  end

  def total_cost
    @total_cost ||= begin
      if started?
        log(@total_cost_message = "started #{screening.starts_at}, UNPICKABLE")
        UNPICKABLE
      elsif priority == 0
        log(@total_cost_message = "priority 0, UNPICKABLE")
        UNPICKABLE
      elsif screening_scheduled?
        log(@total_cost_message = "screening_scheduled, UNPICKABLE")
        UNPICKABLE
      elsif any_conflict_picked?
        log(@total_cost_message = "conflict_picked, UNPICKABLE")
        UNPICKABLE
      elsif film_scheduled? # (ie, by a screening other than this one)
        log(@total_cost_message = "film_scheduled, UNPICKABLE")
        UNPICKABLE
      else
        log(@total_cost_message = "#{total_conflict_cost} - #{calculated_cost} = #{(total_conflict_cost - calculated_cost)}")
        (total_conflict_cost - calculated_cost)
      end
    end
  end

  def total_conflict_cost
    @total_conflict_cost ||= begin
      log "collecting conflict costs (#{autoscheduler.all_conflicting_screening_ids_by_screening_id[screening_id].inspect})"
      costs = conflict_costs
      result = costs.inject(:+) || FREE
      result = -(unopposed_base - costs.count) if result == FREE
      log("total conflict cost: (#{costs.inspect}) => #{result}")
      result
    end
  end

  def unopposed_base
    # considering unopposed screenings, bias toward press screenings
    press? ? 110 : 100
  end

  def conflict_costs
    @conflict_costs ||= conflicting_screening_costs.map {|s| s.cost_as_conflict }
  end

  def cost_as_conflict
    # The cost of *not* picking this film; called for each of the conflicts of
    # another screening we're considering.
    @cost_as_conflict ||= if started?
      log(@cost_as_conflict_message = "(conflict) started #{screening.starts_at}, FREE")
      FREE
    elsif screening_scheduled?
      log(@cost_as_conflict_message = "(conflict) screening_scheduled, UNPICKABLE")
      UNPICKABLE
    elsif film_scheduled?
      log(@cost_as_conflict_message = "(conflict) film_scheduled, FREE")
      FREE
    elsif priority == 0
      log(@cost_as_conflict_message = "(conflict) priority 0, FREE")
      FREE
    else
      log(@cost_as_conflict_message = "(conflict) calculated, #{calculated_cost}")
      calculated_cost
    end
  end

  def calculated_cost
    priority / remaining_screenings_count.to_f
  end

  def reset!
    @total_cost = @total_cost_message = nil \
      unless @total_cost == UNPICKABLE
    @cost_as_conflict = @cost_as_conflict_message = nil \
      unless @cost_as_conflict == UNPICKABLE
    @total_conflict_cost = @conflict_costs = nil
  end

  def priority
    @priority ||= autoscheduler.film_priority(film_id)
  end

  def screening_id
    @screening_id ||= screening.id
  end

  def film_id
    @film_id ||= screening.film_id
  end

  def started?
    screening.starts_at < now
  end

  def pickable?
    total_cost != UNPICKABLE
  end

  def screening_scheduled?
    autoscheduler.screening_id_scheduled?(screening_id)
  end

  def any_conflict_picked?
    autoscheduler.screening_id_conflicts_scheduled?(screening_id)
  end

  def film_scheduled?
    autoscheduler.film_id_scheduled?(film_id)
  end

  def remaining_screenings_count
    autoscheduler.remaining_screenings_count(film_id)
  end

  def conflicting_screening_costs
    autoscheduler.screening_id_conflicts_costs(screening_id)
  end

  def inspect
    "<Cost screening_id=#{screening_id} priority=#{priority.inspect} total_cost=#{total_cost.round(3)} " +
        "cost_as_conflict=#{cost_as_conflict.round(3)} " +
        "conflicts=#{autoscheduler.all_conflicting_screening_ids_by_screening_id[screening_id].inspect} " +
        "conflict_costs=#{conflict_costs.map{|x| x.round(3)}.inspect}>"
  end

  def log(msg)
    autoscheduler.log("Cost(#{screening_id}: #{screening.name}): " + msg)
  end
end
