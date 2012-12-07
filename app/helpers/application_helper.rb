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
    current = options.delete(:current)
    options[:class] = [options[:class], 'active'].compact.join(' ') \
      if (current || current_page?(target))
    content_tag(:li, link_to(title, target), options)
  end

  def cancel_link(model, options={})
    path = if model.respond_to?(:model_name)
      model_name = model.model_name
      if model.new_record?
        # eg festivals_path
        options[:new] || send("#{model_name.route_key}_path")
      else
        # festival_path(festival)
        options[:existing] || send("#{model_name.singular_route_key}_path", model)
      end
    else
      model
    end
    link_to "Cancel", path
  end

  def destroy_button(model)
    link_to('Destroy', model, method: :delete,
                data: { confirm: 'Are you sure?' },
                class: 'btn destroy') \
          unless model.new_record?
  end
end
