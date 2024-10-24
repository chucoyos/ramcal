import { createConsumer } from "@rails/actioncable";

const consumer = createConsumer("/cable"); // Creates a new ActionCable consumer
 consumer.subscriptions.create("LocationChannel", {
  connected() {
    // console.log("Connected to LocationChannel!");
  },

  disconnected() {
    // console.log("Disconnected from LocationChannel.");
  },

  received(data) {
    console.log("Received data: ", data);
  }
});