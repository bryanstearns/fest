Handlers.register 'ScreeningTimePicker', class
  constructor: (el) ->
    return if $("#screening_starts_at_date", el.parentElement).length != 0

    @raw_input = $(el)
    @raw_input.hide()

    @parse_value()
    @create_custom_inputs()

  parse_value: ->
    [date, time, @timezone] = @raw_input.val().split(' ')
    @datetime = new Date("#{date} #{time}")

  create_custom_inputs: ->
    @date_input = $("""<input class="string" id="screening_starts_at_date"
                              type="text" autocomplete="off" value="#{@format_date_value()}">""")
    @time_input = $("""<input class="string" id="screening_starts_at_time"
                              type="text" autocomplete="off" value="#{@format_time_value()}">""")
    @raw_input.before([@date_input, " &mdash; ", @time_input])
    self = this
    @date_input
      .keydown (e) ->
        code = e.keyCode || e.which
        if code == 38 # up arrow
          self.adjust_date(-1)
          e.preventDefault()
        else if code == 40 # down arrow
          self.adjust_date(+1)
          e.preventDefault()
    @time_input
      .keyup (e) ->
        [hour, min] = self.parse_time_value(self.time_input.val())
        self.set_time(hour, min)
      .blur (e) ->
        self.time_input.val(self.format_time_value())

  adjust_date: (offset) ->
    @datetime.setDate(@datetime.getDate() + offset)
    @date_input.val(@format_date_value()).select()
    @update_raw_input()

  set_time: (hour, min) ->
    @datetime.setHours(hour)
    @datetime.setMinutes(min)
    @datetime.setSeconds(0)
    @update_raw_input()

  update_raw_input: ->
    @raw_input.val($.datepicker.formatDate("yy-mm-dd", @datetime) +
                   " #{@padded(@datetime.getHours())}:#{@padded(@datetime.getMinutes())}:00 " +
                   @timezone)

  format_date_value: ->
    $.datepicker.formatDate('DD, MM d', @datetime)

  format_time_value: ->
    hour = @datetime.getHours()
    ampm = if hour < 12
      hour = 12 if hour == 0
      "AM"
    else
      hour -= 12 if hour > 12
      "PM"
    "#{hour}:#{@padded(@datetime.getMinutes())} #{ampm}"

  parse_time_value: (value) ->
    [hour, min] = value.replace(/[^\d:]/g, '').split(':')
    hour = if hour? && hour.length > 0 then parseInt(hour) else 0
    min = if min? && min.length > 0 then parseInt(min) else 0
    if !value.match(/a/i)
      hour += 12 if hour < 12
    else if hour == 12
      hour = 0
    [hour, min]

  padded: (i) ->
    if i < 10 then "0" + i else i
