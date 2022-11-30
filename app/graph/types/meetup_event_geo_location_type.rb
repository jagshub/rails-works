# frozen_string_literal: true

module Graph::Types
  class MeetupEventGeoLocationType < BaseObject
    field :city, String, null: false
    field :country, String, null: false
    field :lat, Float, null: false
    field :lng, Float, null: false
    field :upcoming_events_count, Integer, null: false
  end
end
