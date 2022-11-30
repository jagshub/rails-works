# frozen_string_literal: true

class Cron::Emails::CollectionDigestWorker < ApplicationJob
  queue_as :long_running

  def perform
    date = Time.zone.now

    return if !date.monday? && !date.wednesday? && !date.friday?

    emails   = Set.new
    user_ids = Set.new

    Collection.with_recently_added_posts.find_each do |collection|
      collection.subscriptions.active.find_each do |subscription|
        user_ids << subscription.user_id if subscription.user_id.present?
        emails << subscription.email if subscription.email.present?
      end
    end

    user_ids.each { |user_id| CollectionDigestWorker.perform_later(user_id: user_id) }
    emails.each { |email| CollectionDigestWorker.perform_later(email: email) }
  end
end
