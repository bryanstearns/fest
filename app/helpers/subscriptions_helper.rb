module SubscriptionsHelper
  def autoscheduler_debugging?
    (current_user_is_admin? || Rails.env.development?) && params['debug'].present?
  end

  def debug_menu
    choices = [
        ['As many as possible', 'all'],
        ['All the free ones', 'free'],
        ['Just one', 'one'],
        ['None, just save subscription', 'none']
    ]
    select('subscription', 'debug', choices)
  end

  def unselect_menu_choices(picks)
    choices = []
    future_screening_picks = picks.select {|p| p.screening.try(:future?) }
    if future_screening_picks.present?
      choices << ['Deselect all the future screenings', :future]
      if future_screening_picks.any?(&:auto)
        choices << ['Deselect just the future automatically-scheduled screenings - leave the manually-picked ones', :auto]
      end
      choices << ['Deselect all of them', :all]
    else
      choices << ['Deselect them', :all]
    end
    choices << ['Leave them selected; just fill in around them', :none]
    choices
  end
end
