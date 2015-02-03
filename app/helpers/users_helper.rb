module UsersHelper
  def user_name_and_email(user)
    if user.name.present?
      "\"#{user.name}\" <#{user.email}>"
    else
      user.email
    end
  end

  def user_presenters(users, order)
    users.map {|u| UserPresenter.new(u, order) }.sort
  end

  class UserPresenter
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TranslationHelper

    attr_accessor :details, :user

    def initialize(user, order)
      @user = user
      @order = order
      @details = {}
      summarize
    end

    def summary
      items = times.map {|k| @details[k] }.flatten
      items.map! {|i| content_tag(:li, i) }
      items << failed_sign_in_attempts
      content_tag(:ul, safe_join(items.compact))
    end

    def method_missing(name, *args, &block)
      if @user.respond_to?(name)
        @user.send(name, *args, &block)
      else
        super
      end
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def email_with_status
      flags = []
      flags << 'bounced' if bounced?
      flags << 'unsubscribed' if unsubscribed?
      flags << 'unconfirmed' unless confirmed?
      return email if flags.empty?
      safe_join [ content_tag(:span, email), ' ', content_tag(:strong, flags.join(', ')) ]
    end
  protected
    def sort_key
      @sort_key ||= begin
        key = case @order
          when 'email'
            user.email
          when 'name'
            user.name
          when 'activity'
            times.first && (Time.now - times.first)
        end
        [key, user.id]
      end
    end

    def times
      @details.keys.sort.reverse
    end

    def summarize
      add_current_sign_in
      add_last_sign_in
      add_remembering
      add_most_recent_pick
      add_reset_sent
      add_confirmation
      add_locked
    end

    def add_current_sign_in
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

    def add_most_recent_pick
      pick = user.picks.order(:updated_at).includes(:festival).last
      add("latest #{pick.festival.slug} pick at #{t pick.updated_at}",
          pick.updated_at) \
        if pick
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

    def failed_sign_in_attempts
      pluralize(user.failed_attempts, "failed attempt") \
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
