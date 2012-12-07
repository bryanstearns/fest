class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::OutputSafetyHelper

  before_filter :log_session_state
  after_filter(:log_memory_usage) unless Rails.env.test?

protected
  def authenticate_admin!
    authenticate_user!
    raise ActiveRecord::RecordNotFound unless current_user.admin?
  end

  def log_session_state
    session_key = Rails.application.config.session_options[:key]
    size = (cookies[session_key] || "").size
    Rails.logger.info("  Session, #{size} bytes: #{request.session.inspect}")
    true
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
