$ ->
  $("#festival_starts_on").datepicker
    dateFormat: "yy-mm-dd"
    defaultDate: "+1w"
    onSelect: (selectedDate) ->
      $("#festival_ends_on").datepicker("option", "minDate", selectedDate)

  $("#festival_ends_on").datepicker
    dateFormat: "yy-mm-dd"
    defaultDate: "+1w"
    onSelect: (selectedDate) ->
      $("#festival_starts_on").datepicker("option", "maxDate", selectedDate)
