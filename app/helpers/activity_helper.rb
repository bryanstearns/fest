module ActivityHelper
  def activity_details(activity)
    result = []
    result << "festival: #{activity.festival.slug}" \
      if activity.festival_id?
    result << "subject: #{activity_inspection(activity.subject, :subject, activity)}" \
      if activity.subject_id?
    result << "target: #{activity_inspection(activity.target, :target, activity)}" \
      if activity.target_id?
    activity.details.each do |(k, v)|
      result << safe_join([k, ": ", activity_inspection(v, k, activity)])
    end
    safe_join(result, '<br>'.html_safe)
  end

  def activity_inspection(value, key=nil, activity=nil)
    return value.inspect_for_activity \
      if value.respond_to?(:inspect_for_activity)

    if key && activity
      if value.nil? && activity.respond_to?("#{key}_type") && activity.respond_to?("#{key}_id")
        return "deleted (#{activity.send("#{key}_type")} #{activity.send("#{key}_id")})"
      end
      inspector = "inspect_#{key}"
      return send(inspector, value, activity) if respond_to?(inspector)
    end

    return "#{value.class.name} #{value.to_param}" \
      if ![String, TrueClass, FalseClass, NilClass].include?(value.class) && value.respond_to?(:to_param)

    value.inspect
  end

  def inspect_screenings(screening_ids, activity)
    screening_ids = screening_ids.to_a.sort
    button = activity.restorable? \
      ? button_to("Restore Screenings",
                  restore_admin_activity_path(activity.id),
                  class: "btn btn-xs btn-default") \
      : ""
    ("(#{screening_ids.count}) ##{screening_ids.hash.abs.to_s(16).slice(0,6)} " +
      button).html_safe
  end
end
