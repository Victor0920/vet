import { Controller } from "@hotwired/stimulus"

// Several images for one file input, with a thumbnail and a ✕ for each before the form is sent.
// Picking again ADDS to the list (a plain file input would replace it), and a screenshot pasted
// anywhere in the form (Cmd/Ctrl+V) is added too. Up to `max`; extra ones are dropped with a notice.
// <form data-controller="images-preview" data-images-preview-max-value="5" data-action="paste->images-preview#paste">
//   <input type="file" multiple data-images-preview-target="input" data-action="change->images-preview#add">
//   <ul data-images-preview-target="list"></ul>
//   <template data-images-preview-target="template"><li><img><button type="button">✕</button></li></template>
//   <p hidden data-images-preview-target="limit">Up to 5 images</p>
// </form>
export default class extends Controller {
  static targets = ["input", "list", "template", "limit"]
  static values = { max: { type: Number, default: 5 } }

  connect() {
    this.files = []
  }

  disconnect() {
    this.revokeUrls()
  }

  // The input now holds only what was just picked: add it to the files already chosen
  add() {
    this.append(Array.from(this.inputTarget.files))
  }

  // A screenshot copied to the clipboard (e.g. Cmd+Shift+Ctrl+4 on a Mac, then Cmd+V in the message)
  paste(event) {
    const images = Array.from(event.clipboardData?.files || []).filter((file) => file.type.startsWith("image/"))
    if (images.length === 0) return // plain text: let it paste normally

    event.preventDefault()
    this.append(images)
  }

  remove(event) {
    this.files.splice(Number(event.currentTarget.dataset.index), 1)
    this.sync()
  }

  append(files) {
    const room = this.maxValue - this.files.length
    this.files.push(...files.slice(0, Math.max(room, 0)))
    this.sync(files.length > room)
  }

  // Puts this.files back into the input (DataTransfer is the only way to build a FileList)
  // and redraws the thumbnails
  sync(overLimit = false) {
    const transfer = new DataTransfer()
    this.files.forEach((file) => transfer.items.add(file))
    this.inputTarget.files = transfer.files

    this.revokeUrls()
    this.listTarget.replaceChildren(...this.files.map((file, index) => this.thumbnail(file, index)))
    this.listTarget.hidden = this.files.length === 0
    this.limitTarget.hidden = !overLimit
  }

  thumbnail(file, index) {
    const item = this.templateTarget.content.firstElementChild.cloneNode(true)
    const image = item.querySelector("img")
    image.src = URL.createObjectURL(file)
    image.alt = file.name
    item.querySelector("button").dataset.index = index
    return item
  }

  // Each preview URL keeps its file in memory until it's released
  revokeUrls() {
    this.listTarget.querySelectorAll("img").forEach((image) => URL.revokeObjectURL(image.src))
  }
}
