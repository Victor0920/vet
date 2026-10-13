module CalendarHelper
  SLOT_MINUTES = 15 # if you change this, also change --slots-per-hour in calendar.css

  # "Tuesday, 6 October 2026" / "5 Oct – 11 Oct 2026" / "October 2026"
  def calendar_title
    case @view
    when "week"  then "#{l(@days.first, format: :calendar_week_start)} – #{l(@days.last, format: :calendar_week_end)}"
    when "month" then l(@date, format: :calendar_month)
    else l(@date, format: :calendar_day)
    end
  end

  # The current calendar settings with some changed, e.g. calendar_params(view: "day")
  def calendar_params(**changes)
    { view: @view, date: @date, store_id: @store.id, room_id: @room&.id, customer_id: @customer&.id }.merge(changes).compact
  end

  # The date one step back (-1) or forward (1) in the current view
  def calendar_step_date(direction)
    case @view
    when "week"  then @date + direction.weeks
    when "month" then @date + direction.months
    else @date + direction.days
    end
  end

  # Opening hours from Settings → Appointments and calendar (Enterprise#calendar_opens_at/closes_at)
  def calendar_day_start(day) = calendar_time_on(day, Current.enterprise.calendar_opens_at)
  def calendar_day_end(day) = calendar_time_on(day, Current.enterprise.calendar_closes_at)

  # "08:30" on that day, in the app's time zone
  def calendar_time_on(day, hh_mm)
    hour, min = hh_mm.split(":").map(&:to_i)
    day.in_time_zone.change(hour: hour, min: min)
  end

  # Start time of every slot between opening and closing
  def calendar_slots(day)
    slots = []
    time = calendar_day_start(day)
    while time < calendar_day_end(day)
      slots << time
      time += SLOT_MINUTES.minutes
    end
    slots
  end

  # CSS placing a block on the grid, e.g. "grid-row: 5 / span 6" for 09:00–10:30.
  # Clipped to opening hours; nil if it falls completely outside them.
  def calendar_position(starts_at, ends_at, day)
    from = [ starts_at, calendar_day_start(day) ].max
    to   = [ ends_at, calendar_day_end(day) ].min
    return if to <= from

    slot_seconds = SLOT_MINUTES * 60
    first_row = ((from - calendar_day_start(day)) / slot_seconds).floor + 1
    rows      = ((to - from) / slot_seconds).ceil
    "grid-row: #{first_row} / span #{rows}"
  end

  # The appointments (already loaded in @appointments) that touch this day
  def appointments_on(day)
    @appointments.select { |appointment| appointment.starts_at < day.end_of_day && appointment.ends_at > day.beginning_of_day }
  end

  # Free [from, to] periods between one room's appointments, within opening hours
  def room_gaps(appointments, day)
    gaps = []
    cursor = calendar_day_start(day)

    appointments.sort_by(&:starts_at).each do |appointment|
      gap_end = [ appointment.starts_at, calendar_day_end(day) ].min
      gaps << [ cursor, gap_end ] if gap_end > cursor
      cursor = [ cursor, appointment.ends_at ].max
    end

    gaps << [ cursor, calendar_day_end(day) ] if cursor < calendar_day_end(day)
    gaps
  end
end
