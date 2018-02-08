if Rails.env.development?
  desc "Debug something (see lib/tasks/debug.rake)"
  task debug: :environment do
    s = "->(priority, remscr) { priority / Math.log(remscr * 4) }"
    puts "#{s}"
    f = eval(s)
    puts "p: #{[1, 2, 3, 4].join('  ')}"
    [1, 2, 4, 8].each do |priority|
      print "#{priority}: "
      [1, 2, 3, 4].each do |remscr|
        print "#{f.(priority, remscr)} "
      end
      puts
    end
  end

  #   festival = Festival.find_by_slug("piff_2018")
  #   user = User.find(293)
  #   festival.reset_screenings(user)
  #
  #   Rails.logger = Logger.new(STDOUT)
  #
  #   def pick_screening(user, festival, screening_id)
  #     film_id = Screening.find(screening_id).film_id
  #     pick = user.picks.find_or_initialize_for(film_id)
  #     pick.screening_id = screening_id
  #     pick.save!
  #   end
  #
  #   [7737, 7738, 7739, 7740].each {|screening_id| pick_screening(user, festival, screening_id) }
  #
  #   def run_autoscheduler(user, festival, subscription_params)
  #     subscription = user.subscription_for(festival, create: true)
  #     updated = subscription.update_attributes(subscription_params)
  #     autoscheduler = AutoScheduler.new(user: user,
  #                                       festival: festival,
  #                                       subscription: subscription)
  #     autoscheduler.run
  #   end
  #
  #   run_autoscheduler(user, festival, {"debug" => "all", "up_to_screening_id" => "7702"})
  #
  #   Rails.logger.debug("rake debug ran autoscheduler; now rerunning...")
  #
  #   run_autoscheduler(user, festival, {"debug" => "one"})
  #
  #   Rails.logger.debug("rake debug done.")
  # end

end
