import { Controller } from "@hotwired/stimulus"

// Searchable dropdown for a long <select>: the invoice line's product/service picker.
// The real <select> stays in the form, just hidden. It's still what gets submitted, and
// picking an option here sets its value and fires "change", so invoice_lines_controller.js
// keeps working without knowing this exists.
// The panel shows the first option (the blank "Custom item") on top, then a search box,
// then every <optgroup> (Products, Services). It's built from the <select> when it opens,
// so a long list costs nothing until it's needed.
// <div data-controller="item-picker"
//      data-item-picker-placeholder-value="Search…" data-item-picker-empty-value="No matches">
//   <label for="…">…</label>
//   <select data-item-picker-target="select">…</select>
// </div>
export default class extends Controller {
  static targets = ["select"]
  static values = { placeholder: String, empty: String }

  connect() {
    this.select = this.selectTarget
    this.label = this.element.querySelector(`label[for="${this.select.id}"]`)

    this.button = document.createElement("button")
    this.button.type = "button"
    this.button.id = `${this.select.id}_picker`
    this.button.className = "input item-picker__button"
    this.button.setAttribute("aria-haspopup", "listbox")
    this.button.setAttribute("aria-expanded", "false")
    if (this.select.hasAttribute("aria-invalid")) {
      this.button.setAttribute("aria-invalid", this.select.getAttribute("aria-invalid"))
    }
    this.button.addEventListener("click", () => (this.panel ? this.close() : this.open()))
    this.button.addEventListener("keydown", (event) => this.buttonKeydown(event))

    // The <label> now names the button (buttons are labelable), not the hidden select
    if (this.label) this.label.htmlFor = this.button.id
    this.select.hidden = true
    this.select.after(this.button)
    this.updateButton()

    this.closeOnOutsideClick = (event) => {
      if (!this.element.contains(event.target)) this.close({ focus: false })
    }
  }

  // Put the page back as Rails rendered it (also keeps Turbo's page cache clean)
  disconnect() {
    this.close({ focus: false })
    this.button.remove()
    this.select.hidden = false
    if (this.label) this.label.htmlFor = this.select.id
  }

  open(initialQuery = "") {
    if (this.panel) return

    this.panel = this.buildPanel()
    // In the lower half of the window there's more room above the button, so open upwards
    const { top, height } = this.button.getBoundingClientRect()
    this.panel.classList.toggle("item-picker__panel--above", top + height / 2 > window.innerHeight / 2)
    this.button.after(this.panel)
    this.button.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.closeOnOutsideClick)

    this.search.value = initialQuery
    this.search.focus()
    this.filter()
  }

  close({ focus = true } = {}) {
    if (!this.panel) return

    this.panel.remove()
    this.panel = null
    this.button.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.closeOnOutsideClick)
    if (focus) this.button.focus()
  }

  // Down/Up arrows open the list; typing a letter opens it with that letter already searched
  buttonKeydown(event) {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault()
      this.open()
    } else if (event.key.length === 1 && event.key !== " " && !event.ctrlKey && !event.metaKey && !event.altKey) {
      event.preventDefault()
      this.open(event.key)
    }
  }

  searchKeydown(event) {
    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault()
        const visible = this.items.filter((item) => !item.hidden)
        const step = event.key === "ArrowDown" ? 1 : -1
        const index = visible.indexOf(this.active) + step
        this.setActive(visible[Math.max(0, Math.min(index, visible.length - 1))])
        break
      }
      case "Enter":
        event.preventDefault() // Enter would otherwise submit the invoice form
        if (this.active) this.choose(this.active.dataset.value)
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
      case "Tab":
        event.preventDefault()
        this.close()
        break
    }
  }

  // Shows the items whose name contains every typed word, ignoring case and accents
  // ("cirugia" finds "Cirugía"). "Custom item" always stays visible.
  filter() {
    const words = normalize(this.search.value).split(/\s+/).filter(Boolean)
    let matches = 0

    this.groups.forEach(({ group, items }) => {
      let groupMatches = 0
      items.forEach((item) => {
        item.hidden = !words.every((word) => item.dataset.search.includes(word))
        if (!item.hidden) groupMatches++
      })
      group.hidden = groupMatches === 0
      matches += groupMatches
    })

    this.emptyMessage.hidden = matches > 0 || words.length === 0
    // While searching, highlight the first match so Enter picks it; otherwise the current choice
    const firstMatch = this.items.find((item) => !item.hidden && item.dataset.value !== "")
    this.setActive(words.length ? firstMatch || this.items[0] : this.selectedItem() || this.items[0])
  }

  setActive(item) {
    this.active?.classList.remove("item-picker__option--active")
    this.active = item
    if (!item) return this.search.removeAttribute("aria-activedescendant")

    item.classList.add("item-picker__option--active")
    this.search.setAttribute("aria-activedescendant", item.id)
    item.scrollIntoView({ block: "nearest" })
  }

  choose(value) {
    if (this.select.value !== value) {
      this.select.value = value
      // invoice_lines_controller.js listens for this to show the price / custom fields
      this.select.dispatchEvent(new Event("change", { bubbles: true }))
    }
    this.updateButton()
    this.close()
  }

  updateButton() {
    this.button.textContent = this.select.selectedOptions[0]?.text || ""
  }

  selectedItem() {
    return this.items.find((item) => item.dataset.value === this.select.value)
  }

  // Panel layout: [Custom item] [search] [scrolling list of groups] [no matches]
  buildPanel() {
    const panel = element("div", "item-picker__panel")
    const listId = `${this.button.id}_list`
    this.items = []
    this.groups = []

    const top = element("div", "item-picker__top")
    top.setAttribute("role", "listbox")
    top.setAttribute("aria-label", this.label?.textContent.trim() || "")

    this.search = element("input", "input item-picker__search")
    this.search.type = "search"
    this.search.placeholder = this.placeholderValue
    this.search.autocomplete = "off"
    this.search.setAttribute("aria-label", this.placeholderValue)
    this.search.setAttribute("role", "combobox")
    this.search.setAttribute("aria-expanded", "true")
    this.search.setAttribute("aria-controls", listId)
    this.search.setAttribute("aria-autocomplete", "list")
    this.search.addEventListener("input", () => this.filter())
    this.search.addEventListener("keydown", (event) => this.searchKeydown(event))

    const list = element("div", "item-picker__list")
    list.id = listId
    list.setAttribute("role", "listbox")

    for (const child of this.select.children) {
      if (child.tagName === "OPTGROUP") {
        const group = element("div", "item-picker__group")
        group.setAttribute("role", "group")
        const heading = element("div", "item-picker__group-label", child.label)
        heading.id = `${listId}_${this.groups.length}`
        group.setAttribute("aria-labelledby", heading.id)
        group.append(heading)

        const items = [...child.children].map((option) => this.buildOption(option))
        group.append(...items)
        list.append(group)
        this.groups.push({ group, items })
      } else {
        // Options outside a group (the blank "Custom item") go above the search box
        top.append(this.buildOption(child))
      }
    }

    this.emptyMessage = element("p", "item-picker__empty", this.emptyValue)
    list.append(this.emptyMessage)

    panel.append(top, this.search, list)
    return panel
  }

  buildOption(option) {
    const item = element("div", "item-picker__option")
    item.id = `${this.button.id}_option_${this.items.length}`
    item.setAttribute("role", "option")
    item.setAttribute("aria-selected", String(option.value === this.select.value))
    item.dataset.value = option.value
    item.dataset.search = normalize(option.text)

    item.append(element("span", "item-picker__name", option.text))
    if (option.dataset.price) item.append(element("span", "item-picker__price", option.dataset.price))

    // mousedown would move focus off the search box (and close nothing); keep it there
    item.addEventListener("mousedown", (event) => event.preventDefault())
    item.addEventListener("mousemove", () => this.active !== item && this.setActive(item))
    item.addEventListener("click", () => this.choose(option.value))

    this.items.push(item)
    return item
  }
}

function element(tag, className, text) {
  const node = document.createElement(tag)
  node.className = className
  if (text !== undefined) node.textContent = text
  return node
}

// "Cirugía Menor" → "cirugia menor"
function normalize(text) {
  return text.normalize("NFD").replace(/\p{Diacritic}/gu, "").toLowerCase().trim()
}
