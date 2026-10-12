import { Controller } from "@hotwired/stimulus"

// A link to a section of the same page that scrolls there smoothly and replays a highlight
// on it every time it's clicked. CSS alone (:target) only plays it the first time, because
// the second click doesn't change the URL. The animation itself lives in CSS, on
// .is-highlighted (see home.css); this only restarts it.
// <a href="#to-bill" data-controller="jump-highlight" data-action="jump-highlight#jump">
export default class extends Controller {
  jump(event) {
    const target = document.querySelector(this.element.hash)
    if (!target) return // nothing to jump to: let the link behave as a normal anchor

    // Stops the browser's instant jump, and Turbo too (it skips clicks already handled)
    event.preventDefault()

    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    target.scrollIntoView({ behavior: reduceMotion ? "auto" : "smooth", block: "start" })

    // Restart the animation: remove the class, force the browser to recalculate the layout
    // (reading offsetWidth does that) so it notices the class was gone, then add it back
    target.classList.remove("is-highlighted")
    void target.offsetWidth
    target.classList.add("is-highlighted")
  }
}
