# frozen_string_literal: true

module Graph::Types
  class GoldenKittyMeetupType < BaseObject
    graphql_name 'GoldenKittyMeetup'

    field :id, ID, null: false
    field :chapter_id, ID, null: false
    field :city, String, null: false
    field :title, String, null: false
    field :venue_address, String, null: false
    field :chapter_location, String, null: true
    field :viewer_joined, Boolean, null: true
    field :url, String, null: true
    field :start_date_iso, Graph::Types::DateTimeType, null: false
    field :end_date_iso, Graph::Types::DateTimeType, null: false
  end
end
