module ActivityHelper
  def record_activity(name, options)
    return if Activity.disabled
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
    Activity.create!(attrs)
  rescue => ex # Make sure that whatever called us doesn't fail because we did.
    Rails.log.info("Recording activity raised #{ex.inspect}")
    def rescued
      yield
    rescue StandardError => e
      Rails.log.info("RESCUED: #{e.inspect}")
    end
    rescued { NewRelic::Agent::notice_error(ex, custom_params: attrs) }
    rescued { Airbrake.notify(ex) }
  end

  def activity_details(activity)
    result = []
    result << "festival: #{activity.festival.slug}" if activity.festival_id?
    if activity.subject_id?
      result << "subject: "
      result << activity_inspection(activity.subject)
    end
    if activity.target_id?
      result << "target: "
      result << activity_inspection(activity.target)
    end
    activity.details.each do |(k, v)|
      result << "#{k}: "
      result << activity_inspection(v)
    end
    safe_join(result, ',<br>'.html_safe)
  end

  def activity_inspection(target)
    return target.inspect_for_activity if target.respond_to?(:inspect_for_activity)
    return "#{target.class.name} #{target.to_param}" if target.respond_to?(:to_param)
    target.inspect
  end
end
