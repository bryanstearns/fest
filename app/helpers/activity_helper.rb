module ActivityHelper
  def activity_details(activity)
    result = []
    result << "festival: #{activity.festival.slug}" \
      if activity.festival_id?
    result << "subject: #{activity_inspection(activity.subject)}" \
      if activity.subject_id?
    result << "target: #{activity_inspection(activity.target)}" \
      if activity.target_id?
    activity.details.each do |(k, v)|
      result << "#{k}: #{activity_inspection(v)}"
    end
    safe_join(result, '<br>'.html_safe)
  end

  def activity_inspection(target)
    return target.inspect_for_activity \
      if target.respond_to?(:inspect_for_activity)

    return "#{target.class.name} #{target.to_param}" \
      if ![String, TrueClass, FalseClass, NilClass].include?(target.class) && target.respond_to?(:to_param)

    target.inspect
  end
end
