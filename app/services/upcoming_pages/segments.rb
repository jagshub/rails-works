# frozen_string_literal: true

module UpcomingPages::Segments
  extend self

  def assign(subscriber:, segment:)
    HandleRaceCondition.call do
      UpcomingPageSegmentSubscriberAssociation.find_or_create_by!(
        upcoming_page_segment_id: segment.id,
        upcoming_page_subscriber_id: subscriber.id,
      )
    end
  end
end
