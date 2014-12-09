Handlers.register 'EscapeToCancel', class
  constructor: (el) ->
    $("html").keyup (e) ->
      code = e.keyCode || e.which
      if code == 27 && !$(e.target).hasClass("hasDatePicker")
        window.location = $(el).attr("href")
        e.preventDefault()
