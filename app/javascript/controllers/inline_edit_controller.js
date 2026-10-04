import { Controller } from "@hotwired/stimulus"

// Swaps a field between its read-only value and a small edit form.
//
// <div data-controller="inline-edit">
//   <div data-inline-edit-target="display">… <button data-action="inline-edit#edit">✎</button></div>
//   <form data-inline-edit-target="form" hidden>… <input data-inline-edit-target="input"></form>
// </div>
export default class extends Controller {
  static targets = ["display", "form", "input"]

  edit() {
    this.displayTarget.hidden = true
    this.formTarget.hidden = false
    this.inputTarget.focus()
  }

  cancel() {
    this.formTarget.reset()
    this.formTarget.hidden = true
    this.displayTarget.hidden = false
  }

  cancelOnEscape(event) {
    if (event.key === "Escape") this.cancel()
  }
}
