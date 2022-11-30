# frozen_string_literal: true

class Stream::Workers::FeedItemsCleanUp < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(target:, verb: nil)
    scope = Stream::FeedItem.for_target(target)
    scope = scope.or(Stream::FeedItem.for_action_object(target)) if target.class.name == 'Comment' || target.class.name == 'Review'
    scope = scope.where(verb: verb) if verb.present?

    scope.includes(:receiver).find_each do |feed_item|
      receiver = feed_item.receiver
      feed_item.destroy
      receiver.refresh_notification_feed_items_unread_count
    end
  end
end
