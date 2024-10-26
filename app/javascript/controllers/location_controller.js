import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location"
export default class extends Controller {
  search(event) {
    const query = event.target.value;

    // Trigger a Turbo visit to fetch the filtered moves
    if (query.length > 0) {
      const url = `/location?location=${encodeURIComponent(query)}`;
      Turbo.visit(url, { action: "replace", frame: "location_list" });
    }
    console.log("searching for:", query);
  }

  selectMove(event) {
    const location = event.target.dataset.location;
    this.element.querySelector("input").value = location; // Set the input field value
    console.log("selected location:", location);
  }

}
