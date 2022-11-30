# frozen_string_literal: true

class Stream::Workers::FeedItemsBatchCleanUp < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(target_ids:, target_type:, verb: nil)
    scope = Stream::FeedItem.where(target_id: target_ids, target_type: target_type)
    if target_type == 'Comment' && target_ids.present?
      scope = scope.or(
        Stream::FeedItem.where(
          'action_objects::varchar[] && ?::varchar[]',
          stringify_for_query(target_ids, target_type),
        ),
      )
    end
    scope = scope.where(verb: verb) if verb.present?

    scope.includes(:receiver).find_each do |feed_item|
      receiver = feed_item.receiver
      feed_item.destroy!
      receiver.refresh_notification_feed_items_unread_count
    end
  end

  private

  def stringify_for_query(ids, type)
    "{#{ ActiveRecord::Base.send(
      :sanitize_sql,
      ids.map { |id| "#{ type }_#{ id }" }.join(', '),
    ) }}"
  end
end
