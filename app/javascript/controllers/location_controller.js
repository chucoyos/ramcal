import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  search(event) {
    const query = event.target.value;

    // Trigger a Turbo visit to fetch the filtered moves
    if (query.length > 1) {
      const url = `/location?location=${encodeURIComponent(query)}`;
      Turbo.visit(url, { action: "replace", frame: "location_list" });
    } else {
      this.clearLocationList();
    }
  }

  clearLocationList() {
    const locationList = this.element.querySelector("#location_list");
    if (locationList) {
      locationList.innerHTML = ''; // Clear the list
    }
  }

  selectMove(event) {
    const location = event.target.dataset.location; // Get the location from the clicked element
    const locationInput = this.element.querySelector("input[name='move[location]']");
    if (locationInput) {
      locationInput.value = location; // Set the input value
    }
    this.clearLocationList(); // Hide the list after selection
  }

}
