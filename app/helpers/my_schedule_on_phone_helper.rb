module MyScheduleOnPhoneHelper
  def my_schedule_on_phone?
    user_signed_in? && current_user.has_screenings_for?(@festival)
  end

  def my_schedule_visible_on_phone
    ' visible-xs' if my_schedule_on_phone?
  end

  def my_schedule_hidden_on_phone
    ' hidden-xs' if my_schedule_on_phone?
  end
end
