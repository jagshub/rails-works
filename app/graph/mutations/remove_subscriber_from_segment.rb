# frozen_string_literal: true

module Graph::Mutations
  class RemoveSubscriberFromSegment < BaseMutation
    argument_record :upcoming_page_segment, UpcomingPageSegment, required: true, authorize: :edit
    argument_record :upcoming_page_subscriber, UpcomingPageSubscriber, required: true

    returns Graph::Types::UpcomingPageSegmentType

    def perform(upcoming_page_segment:, upcoming_page_subscriber:)
      UpcomingPageSegmentSubscriberAssociation.find_by!(
        upcoming_page_segment: upcoming_page_segment,
        upcoming_page_subscriber: upcoming_page_subscriber,
      ).destroy

      upcoming_page_segment
    end
  end
end
