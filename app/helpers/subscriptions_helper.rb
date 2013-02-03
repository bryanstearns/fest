module SubscriptionsHelper
  def unselect_menu
    choices = [
        ['Unselect just the future screenings', 'future'],
        ['Unselect all of them', 'all'],
        ['Leave them selected; just fill in around them', 'none']
    ]
    select('subscription', 'unselect', choices)
  end

  def debug_menu
    choices = [
        ['As many as possible', ''],
        ['All the free ones', 'free'],
        ['Just one', 'one'],
        ['None, just save subscription', 'none']
    ]
    select('subscription', 'debug', choices)
  end
end
