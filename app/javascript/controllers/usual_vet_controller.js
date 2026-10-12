import { Controller } from "@hotwired/stimulus"

// Picking a pet selects its usual vet as the employee, and says why under the select.
// <form data-controller="usual-vet" data-usual-vet-message-value="Selecting %{name}…">
//   <select data-usual-vet-target="employee">…</select>
//   <p data-usual-vet-target="hint" hidden></p>
//   <select data-usual-vet-target="pet" data-action="change->usual-vet#select">
//     <option data-usual-employee-id="3">…</option>
//   </select>
// </form>
export default class extends Controller {
  static targets = ["pet", "employee", "hint"]
  static values = { message: String }

  select() {
    const employeeId = this.petTarget.selectedOptions[0]?.dataset.usualEmployeeId
    // The usual vet may not be in the list (e.g. removed from this enterprise)
    const employeeOption = employeeId && this.employeeTarget.querySelector(`option[value="${employeeId}"]`)

    if (!employeeOption) {
      this.hintTarget.hidden = true
      return
    }

    this.employeeTarget.value = employeeId
    // Let anything listening (like unsaved-changes) know the employee changed
    this.employeeTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.hintTarget.textContent = this.messageValue.replace("%{name}", employeeOption.textContent.trim())
    this.hintTarget.hidden = false
  }
}
