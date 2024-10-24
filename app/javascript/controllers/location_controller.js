import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  connect() {
    console.log("Connected to LocationController!");
  }

  change(event) {
    console.log("Location changed to:", event.target.value);
  }
}
