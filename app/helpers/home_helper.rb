module HomeHelper
  def needs_admin_attention?
    !enabled?(:site) || !enabled?(:sign_in) || !enabled?(:sign_up)
  end

  def form_for_flag(flag)
    current_value = enabled?(flag)
    description, new_value = case current_value
    when true
      ["enabled", false]
    when false
      ["disabled", true]
    else
      [current_value.inspect, nil]
    end
    if new_value.nil?
      content_tag(:span, description, class: 'flag')
    else
      form_tag(admin_enabled_flag_path(flag.to_s), method: :put) do
        hidden_field_tag(:value, new_value) + submit_tag(description, class: description)
      end
    end
  end

  def call_to_action
    festival = Festival.current || Festival.upcoming
    banner = if festival
      if enabled?(:sign_up) && festival.published?
        msg =  "Now playing:"
        button = link_to("Get Started (it's free!)",
                         festival_priorities_path(festival),
                         class: 'btn btn-large btn-success')
      else
        msg =  "Coming soon:"
        button = link_to("Check back in a few weeks!",
                         festival_priorities_path(festival),
                         class: 'btn btn-large', disabled: 'disabled',
                         onclick: 'return false;')
      end
      content_tag(:h4, msg) + content_tag(:h2, festival.name) + button
    else
      # no current/upcoming festival, even if signups are enabled.
      content_tag(:h4, "(Closed for the winter - check back soon!)")
    end
    content_tag(:div, banner, id: "nowplaying")
  end
end
