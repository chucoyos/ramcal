// Import all the channels to be used by Action Cable
// import "../../assets/channels/notification_channel.js";
import { Application } from "@hotwired/stimulus"
import "channels";
import "channels/notification_channel";
import "channels/location_channel";

const application = Application.start()

