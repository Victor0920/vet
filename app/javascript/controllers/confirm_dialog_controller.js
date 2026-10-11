import { Controller } from "@hotwired/stimulus"

// Styled replacement for window.confirm() (shared/_confirm_dialog.html.erb, rendered in the layout).
//
// confirm(message, { confirmLabel }) opens the dialog and returns a Promise:
// true for the confirm button, false for Cancel, Esc or a click outside.
// choose(message, { confirmLabel, alternateLabel }) also shows a third, main button and
// resolves to which one was clicked: "confirm", "alternate" or "cancel".
// Unlike window.confirm() it doesn't freeze the page while waiting, so callers
// have to wait for the Promise (await / .then) instead of reading a return value.
//
// Turbo uses it for every data-turbo-confirm; the form's data-confirm-button,
// if any, labels the confirm button (e.g. "Delete").
export default class extends Controller {
  static targets = ["message", "confirmButton", "alternateButton"]
  static values = { confirmLabel: String }

  connect() {
    Turbo.config.forms.confirm = (message, form) =>
      this.confirm(message, { confirmLabel: form.dataset.confirmButton })
  }

  async confirm(message, { confirmLabel } = {}) {
    return (await this.choose(message, { confirmLabel })) === "confirm"
  }

  choose(message, { confirmLabel, alternateLabel } = {}) {
    this.messageTarget.textContent = message
    this.confirmButtonTarget.textContent = confirmLabel || this.confirmLabelValue
    this.alternateButtonTarget.textContent = alternateLabel || ""
    this.alternateButtonTarget.hidden = !alternateLabel
    // With a main (alternate) button next to it, the red one steps back to a ghost button
    this.confirmButtonTarget.classList.toggle("btn--danger", !alternateLabel)
    this.confirmButtonTarget.classList.toggle("btn--danger-ghost", !!alternateLabel)

    this.element.returnValue = ""
    this.element.showModal()

    // <form method="dialog"> sets returnValue to the clicked button's value; Esc leaves it ""
    return new Promise((resolve) => {
      this.element.addEventListener("close", () => resolve(this.element.returnValue || "cancel"), { once: true })
    })
  }

  // A click on the dark backdrop lands on the <dialog> itself (the panel is its child)
  backdropClick(event) {
    if (event.target === this.element) this.element.close()
  }
}
