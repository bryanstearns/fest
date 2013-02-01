
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::OutputSafetyHelper
  include EnabledFlags::ControllerStuff

  before_filter :log_session_state
  after_filter(:log_memory_usage) unless Rails.env.test?

  delegate :current_user_is_admin?, :current_page?, to: :view_context

  rescue_from DisabledByFlag do |e|
    case e.flag
    when :sign_in
      flash[:alert] =
        "Sorry, signing in is temporarily unavailable while I make the site " +
        "better. This shouldn't take long - come back in a bit to sign back " +
        "in; feel free to browse around in the meantime."
      redirect_to root_path
    when :sign_up
      redirect_to sign_ups_off_path
    else
      render "home/maintenance", status: :service_unavailable
    end
  end

  def check_festival_access
    # Called by unprivileged operations: does nothing on public festivals, but
    # raises if the festival isn't public and the user doesn't have access.
    raise(ActiveRecord::RecordNotFound) \
      unless @festival \
        && (@festival.published || current_user_is_admin? #|| \
            #(logged_in? && (current_user.subscription_for(@festival).admin \
                            #rescue false))
           )
  end

protected
  def authenticate_admin!
    authenticate_user!
    raise ActiveRecord::RecordNotFound unless current_user.admin?
  end

  def load_picks_for_current_user
    @picks = user_signed_in? ? @festival.picks_for(current_user) : []
  end

  def log_session_state
    session_key = Rails.application.config.session_options[:key]
    size = (cookies[session_key] || "").size
    Rails.logger.info("  Session, #{size} bytes: #{request.session.inspect}")
  end

  def log_memory_usage
    mem = get_memory_usage
    delta = if $old_memory_usage
              change = mem - $old_memory_usage
              " (#{(change < 0) ? '-' : '+'}#{number_to_human_size(change)})"
            end
    Rails.logger.info("Process size after request: #{number_to_human_size(mem)}#{delta}")
    $old_memory_usage = mem
  end

  if RUBY_PLATFORM =~ /darwin/
    def get_memory_usage
      `ps -o rss= -p #{Process.pid}`.to_i * 1024
    end
  else
    def get_memory_usage
      /(\d+)/.match(File.readlines("/proc/#{Process.pid}/status").grep(/\AVmRSS:/).first)
      $1.to_i * 1024
    end
  end
end
