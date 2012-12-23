module UsersHelper
  def user_status(user)
    UserStatus.new(user).summary
  end

  class UserStatus
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TranslationHelper

    attr_accessor :details, :user

    def initialize(user)
      @user = user
      @details = {}
      summarize
    end

    def summary
      times = @details.keys.sort.reverse
      items = times.map {|k| @details[k] }.flatten
      items.map! {|i| content_tag(:li, i) }
      content_tag(:ul, safe_join(items))
    end

  protected
    def summarize
      add_current_sign_in
      add_last_sign_in
      add_remembering
      add_reset_sent
      add_confirmation
      add_failed_sign_in_attempts
      add_locked
    end

    def add_current_sign_in_visit
      add_visit(user.sign_in_count, user.current_sign_in_at,
                user.current_sign_in_ip) \
        if user.current_sign_in_at?
    end

    def add_last_sign_in
      add_visit(user.sign_in_count - 1, user.last_sign_in_at,
                user.last_sign_in_ip) \
        if user.last_sign_in_at? and user.sign_in_count > 1
    end

    def add_remembering
      add("remembering since #{t user.remember_created_at}",
          user.remember_created_at) \
        if user.remember_created_at?
    end

    def add_reset_sent
      add("reset sent #{t user.reset_password_sent_at}",
          user.reset_password_sent_at) \
        if user.reset_password_sent_at?
    end

    def add_confirmation
      if user.confirmed?
        add("active since #{t user.confirmed_at}",
            user.confirmed_at)
      elsif user.confirmation_sent_at?
        add("unconfirmed, confirmation sent at #{t user.confirmation_sent_at}",
            user.confirmation_sent_at)
      else
        add('unconfirmed, no confirmation sent')
      end
    end

    def add_failed_sign_in_attempts
      add(pluralize(user.failed_attempts, "failed attempt")) \
        if user.failed_attempts > 0
    end

    def add_locked
      add("locked at #{t user.locked_at}") \
        if user.locked_at?
    end

    def add(message, time=nil)
      time ||= Time.zone.now
      @details[time] ||= []
      @details[time] << message
    end

    def add_visit(index, time, ip)
      orded = index == 1 ? "First" : index.ordinalize
      add("#{orded} sign-in at #{t time} from #{ip}", time)
    end

    def t(time)
      l time, format: :mdy_hms
    end
  end
end
