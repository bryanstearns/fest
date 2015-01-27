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
    choices = [['Deselect all selected screenings', :all]]
    selected = :none
    future_screening_picks = picks.select {|p| p.screening.try(:future?) }
    if future_screening_picks.present?
      choices << ['Deselect just the future screenings', :future]
      if !future_screening_picks.all?(&:auto_picked?)
        choices << ['Deselect the future automatically-scheduled screenings - leave the manually-picked ones', :auto]
        selected = :auto
      else
        selected = :future
      end
    end
    choices << ['Don\'t deselect any; just fill in around them', :none]
    [choices, selected]
  end

  def unselect_menu(form, picks)
    choices, selected = unselect_menu_choices(picks)
    form.collection_select(:unselect, choices, :last, :first,
                           selected: selected, hide_label: true)
  end
end
