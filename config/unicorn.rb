require 'syslogger'

# What ports/sockets to listen on, and what options for them.
listen "/app/tmp/unicorn_sock", :tcp_nodelay => true, :backlog => 100
working_directory '/app'

# What the timeout for killing busy workers is, in seconds
timeout (ENV['UNICORN_TIMEOUT'] || 60).to_i

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes (ENV['UNICORN_COUNT'] || 4).to_i

# Log to syslog
logger Syslogger.new("fest_#{ENV['RAILS_ENV'] == 'production' ? 'prod' : ENV['RAILS_ENV']}_unicorn")

# What to do before we fork a worker
before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
  oldpid = '/app/tmp/pids/unicorn.pid.oldbin'
  if server.pid != oldpid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(oldpid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # Already done
    end
  end
  sleep 0.5
end

# What to do after we fork a worker
after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  Redis.current.client.reconnect if defined?(Redis)
end

# Where to drop a pidfile
pid '/app/tmp/pids/unicorn.pid'

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

# https://newrelic.com/docs/ruby/ruby-gc-instrumentation
if GC.respond_to?(:enable_stats)
  GC.enable_stats
end

if defined?(GC::Profiler) and GC::Profiler.respond_to?(:enable)
  GC::Profiler.enable
end
