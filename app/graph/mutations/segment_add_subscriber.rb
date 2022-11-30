# frozen_string_literal: true

class Graph::Mutations::SegmentAddSubscriber < Graph::Mutations::BaseMutation
  argument_record :upcoming_page_segment, UpcomingPageSegment, authorize: :edit
  argument_record :upcoming_page_subscriber, UpcomingPageSubscriber

  returns Graph::Types::UpcomingPageSegmentType

  def perform(upcoming_page_segment:, upcoming_page_subscriber:)
    UpcomingPages::Segments.assign(
      segment: upcoming_page_segment,
      subscriber: upcoming_page_subscriber,
    )

    upcoming_page_segment
  end
end
