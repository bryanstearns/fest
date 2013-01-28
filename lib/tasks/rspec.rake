begin
  require 'rspec/core/rake_task'
  have_rspec = true
rescue LoadError
  # Don't complain if we don't have rspec around (like in production)
  have_rspec = false
end

if have_rspec
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
end
