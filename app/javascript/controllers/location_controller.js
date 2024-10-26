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

  selectMove(event) {
    const locationId = event.target.dataset.locationId; // Get the location from the clicked element
    const locationInput = this.element.querySelector(".location-input");
    if (locationInput) {
      locationInput.value = locationId; // Set the input value
    }
    this.clearLocationList(); // Hide the list after selection
  }

  clearLocationList() {
    const locationList = this.element.querySelector("#location_list");
    if (locationList) {
      locationList.innerHTML = ''; // Clear the list
    }
  }

}
