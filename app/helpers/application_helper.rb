module ApplicationHelper
  include EnabledFlags
  include Countries::Helpers

  def autoscheduler_debugging?
    false #user_signed_in? && (Rails.env.development? || current_user.admin?)
  end

  def webfont_link_tag
    families = [
      #"Droid+Serif:400,700,400italic,700italic",
      "Droid+Sans:400,700"
    ].join('|')
    subset = [
      'latin',
      'latin-ext',
    ].join(',')
    href = "http://fonts.googleapis.com/css?family=#{families}&subset=#{subset}"
    content_tag(:link, '', href: href.html_safe, rel: :stylesheet, type: 'text/css')
  end

  def current_user_is_admin?
    user_signed_in? && current_user.admin?
  end

  def mdy_hms(time, null_value='')
    time ? l(time, format: :mdy_hms) : null_value
  end

  def time_range(starts, ends=nil)
    if ends.nil?
      if starts.respond_to? :starts_at
        ends = starts.ends_at
        starts = starts.starts_at
      end
    end
    return nil unless starts && ends # unset
    return l(starts, format: :hmp).strip if starts == ends # it's one time
    same_meridian = (starts.to_date == ends.to_date) &&
                    ((starts.hour < 12) == (ends.hour < 12))
    safe_join [
      localize(starts, format: (same_meridian ? :hm : :hmp)).gsub(/  /, ' ').strip,
      " - ".html_safe,
      localize(ends, format: :hmp).gsub(/  /, ' ').strip
    ]
  end

  def date_range(starts, ends=nil)
    if ends.nil?
      if starts.respond_to? :starts_on
        ends = starts.ends_on
        starts = starts.starts_on
      elsif starts.respond_to? :starts_at
        ends = starts.ends_at.to_date
        starts = starts.starts_at.to_date
      end
    end
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
    link_options = options.delete(:link_options)
    content_tag(:li, link_to(title, target, link_options), options)
  end

  def cancel_link(record, options={})
    scope, model = extract_scope_and_model(record)
    path = if model.respond_to?(:model_name)
      model_name = model.model_name
      if model.new_record?
        # eg festivals_path
        options[:new] || send("#{scope}#{model_name.route_key}_path")
      else
        # festival_path(festival)
        options[:existing] || send("#{scope}#{model_name.singular_route_key}_path", model)
      end
    else
      record
    end
    link_to "Cancel", path
  end

  def destroy_button(record)
    ignored_scope, model = extract_scope_and_model(record)
    link_to('Destroy', record, method: :delete,
                data: { confirm: 'Are you sure?' },
                class: 'btn extra-action') \
          unless model.new_record?
  end

  def extract_scope_and_model(record)
    if record.is_a? Array
      ["#{record.first}_", record.last]
    else
      [nil, record]
    end
  end

  def ajax_progress(model, options={})
    content_tag(:span, '',
                options.merge(class: 'ajax-progress obscured',
                              id: dom_id(model) + "_progress"))
  end
end
