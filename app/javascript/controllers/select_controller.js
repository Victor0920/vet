import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // This function triggers automatically when the select changes
  submit(event) {
    const selectedValue = event.target.value;

    // Example: Fetch data from your controller dynamically
    fetch(`/my_route?value=${selectedValue}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }, // If you want to use Turbo Streams
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}
