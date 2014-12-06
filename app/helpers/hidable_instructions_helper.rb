module HidableInstructionsHelper
  def hidable_instructions(with_button=false, &block)
    content = [
        content_tag(:div, class: 'instructions hidden-print') do
          capture(&block)
        end
    ]
    content << show_hide_instructions_button if with_button
    concat(safe_join(content, "\n"))
  end

  def show_hide_instructions_button
    return '' unless user_signed_in?

    label = safe_join [
      image_tag('fam3silk/information.png', alt: false, title: false),
      ' ',
      content_tag(:span, "Hide"),
      " instructions"
    ]
    link_to(label,
            '#',
            'data-handler' => 'ToggleInstructions',
            'data-value' => current_user.hide_instructions.to_s,
            id: "instructions_button",
            class: 'btn btn-small extra-action hidden-print')
  end
end
