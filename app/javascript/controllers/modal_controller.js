import { Controller } from "@hotwired/stimulus"

// Modal shown inside <turbo-frame id="modal">.
//
// - close(): empties the frame. When the modal was opened on its own page
//   (no calendar behind it), the link is followed instead.
// - submitEnd(): after a successful save inside the frame, reload the whole
//   page at the redirect URL so the calendar shows the change.
export default class extends Controller {
  close(event) {
    const frame = this.element.closest("turbo-frame")
    if (!frame || !document.querySelector(".calendar")) return

    event?.preventDefault()
    // Clearing src lets the same link open the modal again later
    frame.removeAttribute("src")
    frame.innerHTML = ""
  }

  async submitEnd(event) {
    const form = event.target
    if (form.dataset.turboFrame === "_top") return // e.g. delete: already a full-page visit

    if (!event.detail.success) return // validation errors re-render inside the modal

    // Show the page Turbo already fetched after the redirect, instead of
    // requesting it again (a second request would lose the flash message).
    const fetchResponse = event.detail.fetchResponse
    const responseHTML = await fetchResponse.responseHTML
    Turbo.visit(fetchResponse.location, {
      action: "advance",
      response: { statusCode: fetchResponse.statusCode, redirected: true, responseHTML }
    })
  }
}
