import { Controller } from "@hotwired/stimulus"

// Submits the form as soon as an input changes, e.g. right after a file is picked.
// <form data-controller="auto-submit">
//   <input type="file" data-action="change->auto-submit#submit">
// </form>
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
