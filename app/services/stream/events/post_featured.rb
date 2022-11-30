# frozen_string_literal: true

module Stream
  class Events::PostFeatured < Events::Base
    BUFFER_FOR_POST_FEATURE_TO_COMPLETE = 10.minutes.freeze
    WORKERS = [
      Stream::Activities::PostLaunched,
      Stream::Activities::PostHunted,
      Stream::Activities::PostMakerListed,
      Stream::Activities::ProductPostLaunch,
    ].freeze

    allowed_subjects [Post]
    should_fanout { |event| event.subject&.featured? }

    fanout_workers do |event|
      post_featured_at = event.subject&.featured_at
      return [] if post_featured_at.blank?

      if post_featured_at.future?
        WORKERS.map { |worker| worker.set(wait_until: post_featured_at + BUFFER_FOR_POST_FEATURE_TO_COMPLETE) }
      else
        WORKERS
      end
    end
  end
end
