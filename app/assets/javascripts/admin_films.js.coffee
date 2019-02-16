$ ->
  $("#film_name").change (e) ->
    name_field = e.target
    name = name_field.value.replace(/^(the )(.*)/i, "$2")
    $.each ['sort_name', 'short_name'], (i, f) ->
      field = $("#film_" + f)[0]
      if field.value == ''
        field.value = name
    field = $("#film_url_fragment")[0]
    if field.value == ''
      field.value = name_field.value.toLowerCase().replace(/\s/g, '-')
