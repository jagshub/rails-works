# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSegmentType < BaseObject
    graphql_name 'UpcomingPageSegment'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :name, String, null: false
    field :subscriber_count, Int, null: false

    field :has_subscriber, Boolean, null: false do
      argument :id, ID, required: false
    end

    def has_subscriber(id:)
      id ? object.upcoming_page_segment_subscriber_associations.where(upcoming_page_subscriber_id: id).exists? : false
    end

    def subscriber_count
      object.upcoming_page_subscribers.confirmed.count
    end
  end
end
