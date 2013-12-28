
def mass_assign_and_save(object, values={})
  values.each {|k, v| object.send("#{k}=", v) }
  #puts "Creating #{object.inspect}"
  object.save!
  object
end

class Hash
  def to_hwia
    HashWithIndifferentAccess.new(self)
  end
end

desc "Clone the last festival in this GROUP for testing"
task clone_festival: :environment do
  abort("Not in production!") if Rails.env.production?

  Festival.transaction do
    old_group = ENV["GROUP"] || abort("You forgot GROUP=")
    old_fest = Festival.where(slug_group: old_group).order(:starts_on).last!
    abort("Already exists? (Last festival in this group, #{old_fest.slug}, isn't over yet)") \
      unless old_fest.ends_on < Date.today

    new_fest_slug = old_fest.slug_group + "_#{old_fest.starts_on.year + 1}"
    abort("festival #{new_fest_slug} already exists!") \
      if Festival.where(slug: new_fest_slug).exists?

    new_fest = mass_assign_and_save(Festival.new,
        slug: new_fest_slug,
        slug_group: old_fest.slug_group,
        name: old_fest.name + " Testing",
        place: old_fest.place,
        main_url: old_fest.main_url,
        updates_url: old_fest.updates_url,
        starts_on: old_fest.starts_on + 1.year,
        ends_on: old_fest.ends_on + 1.year,
        published: true,
        scheduled: true,
        revised_at: Time.now,
        has_press: old_fest.has_press)
    # puts "Created festival #{new_fest.inspect}"
    old_fest.locations.each {|l| new_fest.locations << l }
    # puts "  Added #{new_fest.reload.locations.count} location(s)"

    old_fest.films.each do |old_film|
      new_film_attributes = old_film.attributes.to_hwia \
        .except(:id, :festival_id, :created_at, :updated_at)
      new_film = mass_assign_and_save(new_fest.films.build, new_film_attributes)
      # puts "Film: #{new_film.inspect}"

      old_film.screenings.each do |old_screening|
        new_screening_attributes = old_screening.attributes.to_hwia \
          .except(:id, :festival_id, :film_id, :created_at, :updated_at) \
          .merge(starts_at: old_screening.starts_at + 1.year,
                 ends_at: old_screening.ends_at + 1.year,
                 festival_id: new_fest.id, film_id: new_film.id)
        new_screening = mass_assign_and_save(new_fest.screenings.build,
            new_screening_attributes)
        # puts "  Screening: #{new_screening.inspect}"
      end
    end

    # raise ActiveRecord::Rollback
    puts "Created festival #{new_fest.slug}"
  end
end
