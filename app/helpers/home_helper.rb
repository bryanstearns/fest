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
end
