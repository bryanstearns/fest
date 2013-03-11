desc "generate a festival schedule PDF"
task pdf: :environment do
  slug = ENV['SLUG']
  festival = slug ? Festival.where(slug: slug).first! \
                  : Festival.order(:starts_on).last!
  filename = ENV['PDF'] || "#{festival.slug}.pdf"
  user = ENV['EMAIL'] && User.where(email: ENV['EMAIL']).first!
  picks = user && festival.picks_for(user)
  subscription = user && user.subscription_for(festival)
  puts "Generating '#{filename}'..."
  pdf = PrawnHelper::SchedulePDF.new(festival: festival,
                                     picks: picks,
                                     subscription: subscription,
                                     user: user).render
  File.open(filename, 'wb') {|f| f.write(pdf) }
end
