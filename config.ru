# This file is used by Rack-based servers to start the application.

if defined?(Unicorn)
  # Restart unicorn workers if their memory grows to some random amount between
  # these limits; check for this every 16 requests, and log the check.
  # Also, restart workers every so often anyway.
  require 'unicorn/worker_killer'
  mb = 1024**2
  use Unicorn::WorkerKiller::Oom, 256*mb, 384*mb, 16, true
  use Unicorn::WorkerKiller::MaxRequests # use defaults
end

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
