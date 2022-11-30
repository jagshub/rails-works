# frozen_string_literal: true

module Graph::Types
  class Upcoming::EventInputType < BaseInputObject
    graphql_name 'UpcomingEventInput'

    argument :title, String, required: true
    argument :description, String, required: true
    argument :banner_uuid, String, required: true
  end
end
