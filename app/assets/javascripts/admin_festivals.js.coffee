# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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
