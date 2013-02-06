module SubscriptionsHelper
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
