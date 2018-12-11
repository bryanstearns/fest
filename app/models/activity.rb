class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :festival
  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  serialize :details, Hash

  cattr_accessor :disabled

  class NoOldScreenings < StandardError; end

  default_scope { order(id: :desc) }

  def self.record(name, options)
    return if disabled
    user_id = options.delete(:user).try(:id) || options.delete(:user_id)
    festival_id = options.delete(:festival).try(:id) || options.delete(:festival_id)
    subject = options.delete(:subject)
    target = options.delete(:target)
    options[:screenings] = user_screening_ids_for_festival(user_id, festival_id) \
      if festival_id && user_id
    attrs = {
        name: name,
        user_id: user_id,
        festival_id: festival_id,
        subject: subject,
        target: target,
        details: options
    }
    Rails.logger.info("Activity: #{attrs.inspect}")
    create!(attrs)
  rescue => ex # Make sure that whatever called us doesn't fail because we did.
    Rails.logger.info("Recording activity raised #{ex.inspect}")
    Rails.logger.debug(ex.backtrace.join("\n")) unless Rails.env.production?
    rescued { NewRelic::Agent::notice_error(ex, custom_params: attrs) }
    rescued { Airbrake.notify(ex) }
  end

  def self.user_screening_ids_for_festival(user_id, festival_id)
    self.user_picks_with_screenings_for_festival(user_id, festival_id)
        .select(:screening_id)
        .map(&:screening_id)
  end

  def self.user_picks_with_screenings_for_festival(user_id, festival_id)
    Pick.where(user_id: user_id, festival_id: festival_id)
        .where("screening_id is not null")
  end

  def restorable?
    details[:screenings].present? && name != "restore_screenings"
  end

  def restore_old_screenings!
    screening_ids = details[:screenings]
    raise NoOldScreenings unless screening_ids.present?

    Activity.user_picks_with_screenings_for_festival(user.id, festival_id).
             update_all(screening_id: nil)

    screenings = Screening.where(id: screening_ids)
    screenings.each do |screening|
      pick = user.picks.find_or_initialize_for(screening.film_id)
      pick.screening_id = screening.id
      pick.save!
    end
    (screenings.count == screening_ids.count) ? :all : :some
  end

private
  def self.rescued
    yield
  rescue StandardError => e
    Rails.logger.info("RESCUED: #{e.inspect}")
  end
end
