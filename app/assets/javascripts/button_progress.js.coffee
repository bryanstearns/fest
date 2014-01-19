Handlers.register 'ButtonProgress', class
  constructor: (el) ->
    el = $(el)
    if $('span.ajax-progress', el.parentNode).length == 0
      $("<span class=\"ajax-progress obscured\"></span>").insertAfter(el)
    el.unbind('click').click (e) ->
      el.attr("disabled", "disabled")
      $('span.obscured', el.parentNode).removeClass('obscured')
      el.closest('form').submit()
