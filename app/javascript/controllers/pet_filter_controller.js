import { Controller } from "@hotwired/stimulus"

// Only shows the pets of the selected customer.
// The pet select stays disabled until a customer is picked.
// <div data-controller="pet-filter">
//   <select data-pet-filter-target="customer" data-action="change->pet-filter#filter">…</select>
//   <select data-pet-filter-target="pet"><option data-customer-id="5">…</option></select>
// </div>
export default class extends Controller {
  static targets = ["customer", "pet"]

  connect() {
    // Keep every option so they can be put back when the customer changes
    this.blankOption = this.petTarget.querySelector('option[value=""]')
    this.petOptions = Array.from(this.petTarget.options).filter((option) => option.value !== "")
    this.filter()
  }

  filter() {
    const customerId = this.customerTarget.value
    const selectedPet = this.petTarget.value
    const matching = this.petOptions.filter((option) => option.dataset.customerId === customerId)

    this.petTarget.replaceChildren(this.blankOption, ...matching)
    // Keep the pet only if it still belongs to the chosen customer
    this.petTarget.value = matching.some((option) => option.value === selectedPet) ? selectedPet : ""
    this.petTarget.disabled = customerId === ""
  }
}
