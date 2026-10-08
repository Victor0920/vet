import { Controller } from "@hotwired/stimulus"

// Shows the picked image before the form is saved.
// <div data-controller="image-preview">
//   <span data-image-preview-target="placeholder">…</span>
//   <img hidden data-image-preview-target="image">
//   <input type="file" data-action="change->image-preview#show">
// </div>
export default class extends Controller {
  static targets = ["placeholder", "image"]

  show(event) {
    const file = event.target.files[0]
    if (!file) return

    this.imageTarget.src = URL.createObjectURL(file)
    this.imageTarget.hidden = false
    this.placeholderTarget.hidden = true
  }
}
