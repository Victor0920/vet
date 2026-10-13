import { Controller } from "@hotwired/stimulus"

// Keeps an appointment's length when its start moves: change the start from 10:00 to 11:00 and
// a 10:00–10:45 appointment becomes 11:00–11:45. Changing the end sets a new length to keep.
// <div data-controller="appointment-duration">
//   <input type="datetime-local" data-appointment-duration-target="start" data-action="change->appointment-duration#startChanged">
//   <input type="datetime-local" data-appointment-duration-target="end" data-action="change->appointment-duration#endChanged">
// </div>
export default class extends Controller {
  static targets = ["start", "end"]

  // The length the form opened with: the default one for a new appointment, the real one when editing
  connect() {
    this.rememberDuration()
  }

  startChanged() {
    const start = this.parse(this.startTarget.value)
    if (!start || !this.duration) return

    // setMinutes adds clock time, so it stays right on the night the clocks change
    start.setMinutes(start.getMinutes() + this.duration)
    this.endTarget.value = this.format(start)
  }

  endChanged() {
    this.rememberDuration()
  }

  // In minutes. Only a positive length is worth keeping (an end before the start is a mistake the server reports)
  rememberDuration() {
    const start = this.parse(this.startTarget.value)
    const end = this.parse(this.endTarget.value)
    if (start && end && end > start) this.duration = Math.round((end - start) / 60000)
  }

  // datetime-local values ("2026-10-19T10:00") have no time zone, so the browser reads them as local time
  parse(value) {
    if (!value) return null
    const date = new Date(value)
    return isNaN(date) ? null : date
  }

  // Back to "YYYY-MM-DDTHH:MM" in local time (toISOString would convert it to UTC)
  format(date) {
    const pad = (number) => String(number).padStart(2, "0")
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
      `T${pad(date.getHours())}:${pad(date.getMinutes())}`
  }
}
