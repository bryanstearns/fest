
task useraddresses: :environment do
  group_size = (ENV["GROUP"] || 25).to_i
  emails = User.all.map(&:email).map(&:downcase).uniq.sort
  groups = emails.in_groups_of(group_size)
  groups.each_with_index do |group, i|
    puts "#{i}: #{group.compact.join(', ')}\n\n"
  end
  puts "#{emails.count} emails in #{groups.count} groups of #{group_size}"
end
