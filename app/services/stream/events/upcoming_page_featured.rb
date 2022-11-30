# frozen_string_literal: true

module Stream
  class Events::UpcomingPageFeatured < Events::Base
    BUFFER_FOR_PAGE_FEATURE_TO_COMPLETE = 10.minutes.freeze
    WORKERS = [Stream::Activities::UpcomingPageLaunched].freeze

    allowed_subjects [UpcomingPage]
    should_fanout { |event| event.subject&.promoted? }

    fanout_workers do |event|
      featured_at = event.subject&.featured_at
      return [] if featured_at.blank?

      if featured_at.future?
        WORKERS.map { |worker| worker.set(wait_until: featured_at + BUFFER_FOR_PAGE_FEATURE_TO_COMPLETE) }
      else
        WORKERS
      end
    end
  end
end
