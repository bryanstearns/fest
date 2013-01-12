desc "Show site flag state"
task flags: :environment do
  [:site, :sign_in, :sign_up].each do |flag|
    puts "#{flag} #{EnabledFlags.enabled?(flag)}"
  end
end
