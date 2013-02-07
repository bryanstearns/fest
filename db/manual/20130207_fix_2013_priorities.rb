fix_mapping = {
    8 => 4,
    4 => 2,
    2 => 1,
    1 => 0
}
festival = Festival.where(slug: 'piff_2013').first
bad_picks = festival.picks.includes(:user, :film).where('created_at > ?', 19.hours.ago)
users = []
bad_picks.each do |pick|
  if pick.priority
    puts "#{pick.user.email}: #{pick.film.name}: #{pick.priority} --> #{fix_mapping[pick.priority]}"
    pick.priority = fix_mapping[pick.priority]
    pick.save!
    users << pick.user
  end
end
puts users.map(&:email).uniq.sort.join(', ')
