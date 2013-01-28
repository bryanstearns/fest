
worker_processes 2
user 'www-data', 'www-data'

working_directory '/var/www/fest_soon/current'
listen '/var/www/fest_soon/shared/tmp/unicorn_sock', backlog: 64
listen 8081, tcp_nopush: true

timeout 30

pid '/var/www/fest_soon/shared/pids/unicorn.pid'

stderr_path '/var/www/fest_soon/shared/log/unicorn.log'
stdout_path '/var/www/fest_soon/shared/log/unicorn.log'

check_client_connection false
preload_app true
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  oldpid = '/var/www/fest_soon/shared/pids/unicorn.pid.oldbin'
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

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  Redis.current.client.reconnect if defined?(Redis)
end
