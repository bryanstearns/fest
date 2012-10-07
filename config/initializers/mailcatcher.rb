# If Mailcatcher is running in one of the non-production environments, use it.
unless %w[cucumber production test].include?(Rails.env)
  begin
    require 'socket'
    TCPSocket.open('127.0.0.1', 1025) {|sock| nil }

    # If we get here, MailCatcher is running.
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :port => 1025,
      :address => '127.0.0.1'
    }
  rescue Errno::ECONNREFUSED
    # No mailcatcher - do nothing
  end
end
