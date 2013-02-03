class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user

  attr_accessor :debug, :skip_autoscheduler, :unselect, :up_to_screening_id

  attr_accessible :debug, :show_press, :skip_autoscheduler, :unselect, :up_to_screening_id
  attr_accessible :debug, :festival_id, :show_press, :unselect,
                  :up_to_screening_id, as: :subscription_creator

  before_save :run_autoscheduler, if: :should_autoschedule?

  def can_see?(screening)
    return false if screening.press && !show_press?
    true
  end

  def autoscheduler
    @autoscheduler ||= AutoScheduler.new(autoscheduler_options)
  end

  def should_autoschedule?
    !new_record? && !skip_autoscheduler && (debug != 'none')
  end

  def run_autoscheduler
    autoscheduler.run
  end

  def autoscheduler_options
    {
      user: user,
      festival: festival,
      show_press: show_press,
      unselect: unselect,
      debug: debug,
      up_to_screening_id: up_to_screening_id
    }
  end

  def autoscheduler_message
    @autoscheduler && autoscheduler.message
  end

  def cost(screening)
    autoscheduler.costs[screening]
  end
end
