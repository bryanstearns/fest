class AutoScheduler
  attr_reader :show_press, :user, :festival, :scheduled_count

  def initialize(options)
    @user = options[:user]
    @festival = options[:festival]
    @show_press = options[:show_press]

    @scheduled_count = 0
  end

  def run
    loop do
      cost, screening, pick = next_best_screening || break
      schedule(pick, screening, cost)
      @scheduled_count += 1
    end
  end
end
