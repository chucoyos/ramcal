import { createConsumer } from "@rails/actioncable";

const consumer = createConsumer(); // Creates a new ActionCable consumer

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    console.log("Connected to NotificationChannel!");
  },

  disconnected() {
    console.log("Disconnected from NotificationChannel.");
  },

  received(data) {
    console.log("Received data: ", data);
  }
});