import { Controller } from "@hotwired/stimulus"

// Warns before leaving a form with unsaved changes.
// <form data-controller="unsaved-changes"
//       data-unsaved-changes-message-value="You have unsaved changes…"
//       data-unsaved-changes-leave-label-value="Leave without saving"
//       data-unsaved-changes-save-label-value="Save and exit"
//       data-unsaved-changes-dirty-value="true">  <- e.g. re-rendered after a failed save
//
// Two kinds of "leaving" need two different events:
// - beforeunload: closing the tab, reloading, typing a URL. The browser shows its own
//   dialog (custom text isn't allowed there).
// - turbo:before-visit: clicking a link inside the app. Turbo swaps the page without a real
//   unload, so beforeunload never fires. The visit is cancelled, the app's confirm dialog asked
//   (confirm_dialog_controller.js), and the visit repeated if the answer is "leave".
//   "Save and exit" submits the form instead; if the save works, the redirect that follows is
//   swapped for the page they were going to (the server's flash message is lost on the way).
//   If it fails, the form comes back with its errors and they stay.
// Known gap: the browser Back button restores Turbo's cached page without either event.
export default class extends Controller {
  static values = { message: String, leaveLabel: String, saveLabel: String, dirty: Boolean }

  connect() {
    this.mark = () => { this.dirtyValue = true }
    // Submitting is a deliberate way out and should never warn (the redirect after it is a Turbo visit too).
    // Any form that changes data counts, e.g. the appointment modal's Delete button, which is its own form;
    // GET forms (searches) don't, as they just reload part of the page.
    // turbo:submit-start rather than submit: it fires only once a data-turbo-confirm was accepted,
    // and never for the confirm dialog's own <form method="dialog">.
    this.reset = (event) => {
      if (event.target === this.element || event.target.method !== "get") this.dirtyValue = false
    }
    this.warnOnUnload = (event) => { if (this.dirtyValue) event.preventDefault() }
    this.warnOnVisit = (event) => {
      // After "Save and exit": the save worked and Turbo is following the server's redirect; go where they meant to
      if (this.exitUrl) {
        const url = this.exitUrl
        this.exitUrl = null
        if (event.detail.url !== url) {
          event.preventDefault()
          Turbo.visit(url)
        }
        return
      }

      if (!this.dirtyValue) return

      // The dialog doesn't block like window.confirm(): stop this visit now, redo it once they've chosen
      event.preventDefault()
      const url = event.detail.url
      this.askBeforeLeaving().then((choice) => {
        if (choice === "confirm") {
          this.dirtyValue = false
          Turbo.visit(url)
        } else if (choice === "alternate") {
          this.saveAndVisit(url)
        }
      })
    }

    this.element.addEventListener("input", this.mark)
    this.element.addEventListener("change", this.mark)
    document.addEventListener("turbo:submit-start", this.reset)
    window.addEventListener("beforeunload", this.warnOnUnload)
    document.addEventListener("turbo:before-visit", this.warnOnVisit)
  }

  disconnect() {
    this.element.removeEventListener("input", this.mark)
    this.element.removeEventListener("change", this.mark)
    document.removeEventListener("turbo:submit-start", this.reset)
    window.removeEventListener("beforeunload", this.warnOnUnload)
    document.removeEventListener("turbo:before-visit", this.warnOnVisit)
  }

  // Resolves to "confirm" (leave without saving), "alternate" (save and exit) or "cancel"
  askBeforeLeaving() {
    const element = document.getElementById("confirm-dialog")
    const dialog = element && this.application.getControllerForElementAndIdentifier(element, "confirm-dialog")
    if (!dialog) return Promise.resolve(confirm(this.messageValue) ? "confirm" : "cancel") // layout without the dialog

    return dialog.choose(this.messageValue, { confirmLabel: this.leaveLabelValue, alternateLabel: this.saveLabelValue })
  }

  saveAndVisit(url) {
    // reportValidity() shows the browser's hints (e.g. an empty required field) and stops here,
    // as requestSubmit() would, but without leaving exitUrl set for a later, ordinary save
    if (!this.element.reportValidity()) return

    this.exitUrl = url
    // requestSubmit(), not submit(): it goes through Turbo and fires the submit events, like clicking Save.
    // A failed save re-renders the page (422), which replaces this controller and forgets exitUrl.
    this.element.requestSubmit()
  }
}
