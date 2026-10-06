import { Controller } from "@hotwired/stimulus"

// Submits the form a moment after the user stops typing, so a search runs
// once per pause instead of once per keystroke.
// <form data-controller="search">
//   <input type="search" data-action="input->search#submit">
// </form>
export default class extends Controller {
  static values = { delay: { type: Number, default: 250 } }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
