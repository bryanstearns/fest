module ApplicationHelper
  def current_user_is_admin?
    user_signed_in? && current_user.admin?
  end
end
