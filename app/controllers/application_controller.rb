class SiteClosed < StandardError; end

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::OutputSafetyHelper

  before_filter :are_we_open
  before_filter :log_session_state
  after_filter(:log_memory_usage) unless Rails.env.test?

  delegate :current_user_is_admin?, :current_page?, :enabled?,
           to: :view_context

  rescue_from SiteClosed do
    render "home/maintenance", status: :service_unavailable
  end

  def check_festival_access
    # Called by unprivileged operations: does nothing on public festivals, but
    # raises if the festival isn't public and the user doesn't have access.
    raise(ActiveRecord::RecordNotFound) \
      unless @festival \
        && (@festival.public || current_user_is_admin? #|| \
            #(logged_in? && (current_user.subscription_for(@festival).admin \
                            #rescue false))
           )
  end

protected
  def are_we_open
    raise SiteClosed unless (enabled?(:site) || current_user_is_admin? ||
                             current_page?(maintenance_path))
  end

  def authenticate_admin!
    authenticate_user!
    raise ActiveRecord::RecordNotFound unless current_user.admin?
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
