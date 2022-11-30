# frozen_string_literal: true

module Stream
  class Activities::CommentCreated < Activities::Base
    ALLOWED_TARGET_TYPES = [Post, Recommendation, Discussion::Thread, Review].freeze

    verb 'comment'
    create_when :new_object

    target { |event| event.subject&.subject }
    connecting_text do |receiver_id, comment, target|
      return Stream::FeedItem::MENTIONED_YOU_IN if comment.mentioned_user_ids.include? receiver_id
      return Stream::FeedItem::COMMENTED_ON_YOUR if target.is_a?(Recommendation) && target.user_id == receiver_id
      return Stream::FeedItem::REPLIED_TO_YOUR_REVIEW if target.is_a?(Review) && target.user_id == receiver_id

      Stream::FeedItem::COMMENTED_ON
    end

    notify_user_ids do |event, target, _actor|
      return [] unless ALLOWED_TARGET_TYPES.include? target.class

      user_ids = []

      comment = event.subject
      user_ids += comment.mentioned_user_ids
      # NOTE(Dhruv): Create feed item in the target's owner feed if top level comment
      user_ids << target.user_id if target.user.present? && comment.parent.blank?

      user_ids += target.subscribers.with_user.pluck(:user_id) if Subscribe.subscribeable?(target)
      user_ids
    end
  end
end
