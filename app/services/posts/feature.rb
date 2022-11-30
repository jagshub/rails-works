# frozen_string_literal: true

module Posts::Feature
  extend self

  def call(post, featured_at:)
    featured_at = parse_time(featured_at)

    post.scheduled_at = featured_at if featured_at.present?
    post.featured_at = featured_at
    post.save!

    if featured_at.blank?
      Stream::Workers::FeedItemsCleanUp.perform_later(target: post)
      Posts::CleanUpRankingsWorker.perform_later(post: post)
    else
      Posts::NotifyAboutPostSubmissionWorker.perform_later(post)
      Posts::UpdateCurrentDailyRankingWorker.perform_later
    end

    post
  end

  private

  def parse_time(value)
    return if value.blank?
    return value unless value.is_a? String

    Time.zone.parse(value)
  rescue ArgumentError
    nil
  end
end
