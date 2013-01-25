class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user

  attr_accessor :skip_autoscheduler

  attr_accessible :show_press, :skip_autoscheduler
  attr_accessible :festival_id, :show_press, as: :subscription_creator

  before_save :run_autoscheduler, if: :should_autoschedule?

  def can_see?(screening)
    return false if screening.press && !show_press?
    true
  end

  def autoscheduler
    @autoscheduler ||= AutoScheduler.new(autoscheduler_options)
  end

  def should_autoschedule?
    !new_record? && !skip_autoscheduler
  end

  def run_autoscheduler
    autoscheduler.run
  end

  def autoscheduler_options
    {
      user: user,
      festival: festival,
      show_press: show_press
    }
  end
end
