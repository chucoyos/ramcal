import { Application } from "@hotwired/stimulus"
import "channels";
import "channels/notification_channel";
import "channels/location_channel";

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
