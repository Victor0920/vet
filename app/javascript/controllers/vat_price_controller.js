import { Controller } from "@hotwired/stimulus"

// Keeps the price without VAT, the VAT % and the final price in step while typing.
// Only price and vat are real fields (they're saved); final is a helper with no name,
// so it's never submitted: final = price × (1 + vat / 100).
// <div data-controller="vat-price" data-vat-price-keep-value="price">
//   <input data-vat-price-target="price" data-action="input->vat-price#priceChanged">
//   <input data-vat-price-target="vat" data-action="input->vat-price#vatChanged">
//   <input data-vat-price-target="final" data-action="input->vat-price#finalChanged">
// </div>
// keep: what stays put when the VAT changes. "price" (product/service form): the final price
// moves. "final" (custom invoice lines, where the price without VAT is hidden): the price
// without VAT moves, so the amount typed is what the customer pays.
export default class extends Controller {
  static targets = ["price", "vat", "final"]
  static values = { keep: { type: String, default: "price" } }

  // Fills in the final price from the saved values (or after a failed save)
  connect() {
    this.priceChanged()
  }

  priceChanged() {
    const price = this.number(this.priceTarget)
    this.finalTarget.value = price === null ? "" : this.round(price * this.multiplier, 2).toFixed(2)
  }

  vatChanged() {
    if (this.keepValue === "final") {
      this.finalChanged()
    } else {
      this.priceChanged()
    }
  }

  // 4 decimals, the same as the database, so the final price comes back exactly as typed:
  // 10.00 at 21 % → 8.2645 → 8.2645 × 1.21 = 10.00
  finalChanged() {
    const final = this.number(this.finalTarget)
    this.priceTarget.value = final === null ? "" : String(this.round(final / this.multiplier, 4))
  }

  get multiplier() {
    return 1 + (this.number(this.vatTarget) || 0) / 100
  }

  number(input) {
    return input.value === "" ? null : Number(input.value)
  }

  round(value, decimals) {
    const factor = 10 ** decimals
    return Math.round((value + Number.EPSILON) * factor) / factor
  }
}
