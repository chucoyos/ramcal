import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  connect() {
    // console.log("Connected to LocationController!");
  }

  change(event) {
    const loc = event.target.value
    console.log("Location changed to: ", loc);
  }
}
