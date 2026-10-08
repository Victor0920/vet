import { Controller } from "@hotwired/stimulus"

// Adds and removes invoice lines on the invoice form, and switches each line
// between "existing product" and "custom item" (description + price).
// <section data-controller="invoice-lines">
//   <div data-invoice-lines-target="list">…one data-invoice-lines-target="line" per row…</div>
//   <template data-invoice-lines-target="template">…a blank row using NEW_LINE as its index…</template>
//   <button type="button" data-action="invoice-lines#add">
// </section>
export default class extends Controller {
  static targets = ["list", "template", "line"]

  // Stimulus calls this for every row: the ones rendered by Rails and the ones added later
  lineTargetConnected(line) {
    this.update(line)
  }

  add() {
    // Rails groups each row's fields by index: invoice[invoice_products_attributes][<index>][…].
    // A timestamp gives every new row an index no other row has.
    const html = this.templateTarget.innerHTML.replaceAll("NEW_LINE", Date.now())
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    const line = event.target.closest("[data-invoice-lines-target='line']")
    const id = line.querySelector("input[name$='[id]']")

    if (id?.value) {
      // Saved line: keep only id + _destroy=1 so Rails deletes it on save.
      // Disabling the rest also stops the browser complaining about hidden required fields.
      line.querySelector("input[name$='[_destroy]']").value = "1"
      line.querySelectorAll("input, select").forEach((field) => {
        if (!/\[(id|_destroy)\]$/.test(field.name)) field.disabled = true
      })
      line.hidden = true
    } else {
      // Never saved: just drop it
      line.remove()
    }
  }

  toggle(event) {
    this.update(event.target.closest("[data-invoice-lines-target='line']"))
  }

  // Product picked → show its price, hide and disable description/price.
  // "Custom item" picked → the other way round. Disabled inputs aren't submitted.
  update(line) {
    const select = line.querySelector("[data-product-select]")
    const custom = select.value === ""
    const manual = line.querySelector("[data-manual]")
    const productPrice = line.querySelector("[data-product-price]")

    manual.hidden = !custom
    manual.querySelectorAll("input").forEach((input) => (input.disabled = !custom))

    productPrice.hidden = custom
    productPrice.querySelector("[data-product-price-value]").textContent =
      select.selectedOptions[0]?.dataset.price || "—"
  }
}
