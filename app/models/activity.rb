class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :festival
  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  serialize :details, Hash

  cattr_accessor :disabled

  default_scope { order(:id).reverse_order }

  def self.record(name, options)
    return if disabled
    user_id = options.delete(:user).try(:id) || options.delete(:user_id)
    festival_id = options.delete(:festival).try(:id) || options.delete(:festival_id)
    subject = options.delete(:subject)
    target = options.delete(:target)
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
    rescued { NewRelic::Agent::notice_error(ex, custom_params: attrs) }
    rescued { Airbrake.notify(ex) }
  end

private
  def self.rescued
    yield
  rescue StandardError => e
    Rails.logger.info("RESCUED: #{e.inspect}")
  end
end
