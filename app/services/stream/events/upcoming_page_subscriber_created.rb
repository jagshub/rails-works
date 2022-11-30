# frozen_string_literal: true

module Stream
  class Events::UpcomingPageSubscriberCreated < Events::Base
    BUFFER_FOR_PAGE_FEATURE_TO_COMPLETE = 1.minute.freeze
    WORKERS = [Stream::Activities::UpcomingPageSubscribed].freeze

    allowed_subjects [UpcomingPageSubscriber]
    should_fanout { |event| event.subject&.confirmed? && event.subject&.user.present? }

    fanout_workers do |event|
      featured_at = event.subject&.upcoming_page&.featured_at
      return [] if featured_at.blank?

      if featured_at.future?
        WORKERS.map { |worker| worker.set(wait_until: featured_at + BUFFER_FOR_PAGE_FEATURE_TO_COMPLETE) }
      else
        WORKERS
      end
    end
  end
end
