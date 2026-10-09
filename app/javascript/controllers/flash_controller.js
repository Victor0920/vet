import { Controller } from "@hotwired/stimulus"

// One flash toast (shared/_flash). Fades out after 5 seconds, or straight away when clicked.
// Hovering pauses the countdown, so a message being read doesn't vanish under the mouse.
// The fade animations live in alert.css; this only adds .alert--leaving and removes the element.
// <div class="alert alert--toast" data-controller="flash" data-action="click->flash#dismiss">
export default class extends Controller {
  static values = { timeout: { type: Number, default: 5000 } }

  connect() {
    this.startTimer()
    this.element.addEventListener("mouseenter", this.stopTimer)
    this.element.addEventListener("mouseleave", this.startTimer)
  }

  disconnect() {
    this.stopTimer()
    this.element.removeEventListener("mouseenter", this.stopTimer)
    this.element.removeEventListener("mouseleave", this.startTimer)
  }

  // Arrow functions so they can be passed to addEventListener and still see `this`
  startTimer = () => {
    this.stopTimer()
    this.timer = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  stopTimer = () => clearTimeout(this.timer)

  dismiss() {
    if (this.leaving) return
    this.leaving = true
    this.stopTimer()
    this.element.classList.add("alert--leaving")

    // No animation running (prefers-reduced-motion): remove right away
    const animations = this.element.getAnimations()
    if (animations.length === 0) return this.element.remove()
    Promise.all(animations.map((animation) => animation.finished)).then(() => this.element.remove())
  }
}
