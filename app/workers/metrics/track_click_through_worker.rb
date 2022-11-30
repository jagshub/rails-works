# frozen_string_literal: true

class Metrics::TrackClickThroughWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandlePostgresErrors

  queue_as :tracking

  def perform(post, user, track_code, ip_address, via_application_id = nil)
    # Note (LukasFittl): Atomic +1 on database server to avoid race condition
    Post.increment_counter(:link_visits, post.id)

    track_code = Utf8Sanitize.call(track_code)&.gsub("\u0000", '')

    return unless user.present? || track_code.present?
    return if exists?(post, user, track_code)

    post.link_trackers.create! user: user, track_code: track_code,
                               ip_address: ip_address, via_application_id: via_application_id

    # Note(LukasFittl): We're intentionally running this outside the transaction to avoid deadlocks.
    Post.increment_counter(:link_unique_visits, post.id)
  end

  private

  def exists?(post, user, track_code)
    if user.present?
      post.link_trackers.exists?(user: user)
    else
      post.link_trackers.exists?(track_code: track_code)
    end
  end
end
