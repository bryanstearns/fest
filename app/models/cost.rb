class Cost
  UNPICKABLE = Float::INFINITY

  attr_reader :autoscheduler, :screening

  delegate :now, to: :autoscheduler
  delegate :started?, to: :screening

  def initialize(autoscheduler, screening)
    @autoscheduler = autoscheduler
    @screening = screening
    @cost = nil
  end

  def cost
    # - whether this screening is already started (ie, done) (unpickable!)
    # - whether this screening is picked (unpickable!)
    # - whether its conflicts are picked (unpickable!)
    # - whether this film is picked elsewhere (0)
    # - user-selected priority
    # - how many remaining screenings are there of this film?
    @cost ||= begin
      if started? || screening_scheduled? || any_conflict_picked?
        UNPICKABLE
      elsif film_scheduled? # (ie, by a screening other than this one)
        0
      else
        # For now, assign a simple non-zero cost
        screening.id
      end
    end
  end

  def reset!
    @cost = nil unless (@cost == UNPICKABLE || @cost == 0)
  end

  def started?
    screening.starts_at < now
  end

  def screening_scheduled?
    autoscheduler.screening_id_scheduled?(screening.id)
  end

  def any_conflict_picked?
    autoscheduler.screening_id_conflicts_scheduled?(screening.id)
  end

  def film_scheduled?
    autoscheduler.film_id_scheduled?(screening.film_id)
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
