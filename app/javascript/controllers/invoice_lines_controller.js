import { Controller } from "@hotwired/stimulus"

// Adds and removes invoice lines on the invoice form, and switches each line
// between "existing product or service" and "custom item" (description + price).
// While the "Update stock" switch is on, each product line shows how many units
// are available and its quantity can't go above that (the server checks it too).
// <section data-controller="invoice-lines" data-invoice-lines-available-value="%{count} available">
//   <input type="checkbox" data-invoice-lines-target="stockToggle" data-action="invoice-lines#refresh">
//   <div data-invoice-lines-target="list">…one data-invoice-lines-target="line" per row…</div>
//   <template data-invoice-lines-target="template">…a blank row using NEW_LINE as its index…</template>
//   <button type="button" data-action="invoice-lines#add">
// </section>
export default class extends Controller {
  static targets = ["list", "template", "line", "stockToggle"]
  static values = { available: String }

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

  // The "Update stock" switch changed: every line's limit changes with it
  refresh() {
    this.lineTargets.forEach((line) => this.update(line))
  }

  // Product or service picked → show its price, hide and disable description/price.
  // "Custom item" picked → the other way round. Disabled inputs aren't submitted.
  update(line) {
    const select = line.querySelector("[data-item-select]")
    const custom = select.value === ""
    const manual = line.querySelector("[data-manual]")
    const productPrice = line.querySelector("[data-product-price]")

    manual.hidden = !custom
    manual.querySelectorAll("input").forEach((input) => (input.disabled = !custom))

    productPrice.hidden = custom
    productPrice.querySelector("[data-product-price-value]").textContent =
      select.selectedOptions[0]?.dataset.price || "—"

    this.updateStock(line, custom ? null : select.selectedOptions[0])
  }

  // Shows "· 5 available" and sets the quantity's max, or removes both when the line
  // is a custom item or a service (no data-stock), or the "Update stock" switch is off.
  updateStock(line, option) {
    const quantity = line.querySelector("input[name$='[quantity]']")
    const label = line.querySelector("[data-product-stock]")
    const tracking = this.hasStockToggleTarget && this.stockToggleTarget.checked

    if (!option || !tracking || option.dataset.stock === undefined) {
      quantity.removeAttribute("max")
      label.hidden = true
      return
    }

    // A saved line already took its units out of stock, so editing it may use them again
    let available = Number(option.dataset.stock)
    if (line.dataset.savedItem === option.value) available += Number(line.dataset.savedQuantity)

    quantity.max = available
    label.textContent = `· ${this.availableValue.replace("%{count}", available)}`
    label.classList.toggle("invoice-line__stock--out", available < 1)
    label.hidden = false
  }
}
