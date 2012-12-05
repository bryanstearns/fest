module ApplicationHelper
  def current_user_is_admin?
    user_signed_in? && current_user.admin?
  end

  def date_range(starts, ends)
    return nil unless starts && ends # unset
    return l(starts, format: :mdy) if starts == ends # it's one day

    start_format, end_format = if starts.year != ends.year
      [ :mdy, :mdy ]
    elsif starts.month == ends.month
      [ :md, :dy ]
    else
      [ :md, :mdy ]
    end

    safe_join [
      localize(starts, format: start_format).gsub(/  /, ' ').strip,
      " - ".html_safe,
      localize(ends, format: end_format).gsub(/  /, ' ').strip
    ]
  end

  def link_in_list_to(title, target, options={})
    options[:class] = [options[:class], 'active'].compact.join(' ') \
      if current_page?(target)
    content_tag(:li, link_to(title, target), options)
  end
end
