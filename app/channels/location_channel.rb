class LocationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "location"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast("location", data)
  end
end
