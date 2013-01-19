guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch(%r{features/support/}) { :cucumber }
end

guard 'rspec', :cli => '--drb -r rspec/instafail -f RSpec::Instafail' do
  watch('spec/spec_helper.rb') { "spec" }
  watch('app/controllers/application_controller.rb') { "spec/controllers" }
  watch('config/routes.rb') { "spec/routing" }
  watch(%r{^spec/support/(requests|controllers|mailers|models)_helpers\.rb}) { |m| "spec/#{m[1]}" }
  watch(%r{^spec/.+_spec\.rb})

  watch(%r{^app/controllers/(.+)_(controller)\.rb}) {|m| [
    "spec/routing/#{m[1]}_routing_spec.rb",
     "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb",
     "spec/requests/#{m[1]}_spec.rb"
  ]}

  watch(%r{^app/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/lib/#{m[1]}_spec.rb" }
end

guard 'cucumber', :cli => '--drb' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
