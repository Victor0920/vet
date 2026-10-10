import { Controller } from "@hotwired/stimulus"

// Keeps the invoice form's customer and appointment consistent, so it never sends a pair the
// server refuses (Invoice#customer_matches_appointment):
// - picking an appointment that has a customer fills in that customer
// - picking a customer clears the appointment if it belongs to someone else (or to nobody)
// Each appointment <option> carries data-customer-id (empty when it has no customer).
// <section data-controller="invoice-customer">
//   <select data-invoice-customer-target="customer" data-action="change->invoice-customer#customerChanged">
//   <select data-invoice-customer-target="appointment" data-action="change->invoice-customer#appointmentChanged">
// </section>
export default class extends Controller {
  static targets = ["customer", "appointment"]

  appointmentChanged() {
    if (this.syncing) return

    const customerId = this.appointmentTarget.selectedOptions[0]?.dataset.customerId
    if (customerId) this.set(this.customerTarget, customerId)
  }

  customerChanged() {
    if (this.syncing || this.appointmentTarget.value === "") return

    const appointmentCustomerId = this.appointmentTarget.selectedOptions[0]?.dataset.customerId || ""
    if (appointmentCustomerId !== this.customerTarget.value) this.set(this.appointmentTarget, "")
  }

  // Changes a select from code. Firing "change" lets item_picker_controller.js update the
  // button you see; `syncing` stops this controller reacting to a change it made itself.
  set(select, value) {
    if (select.value === value) return

    select.value = value
    this.syncing = true
    select.dispatchEvent(new Event("change", { bubbles: true }))
    this.syncing = false
  }
}
