# frozen_string_literal: true

module Stream
  class Activities::VoteCreated < Activities::Base
    ALLOWED_TARGET_TYPES = [Comment, Post, Recommendation].freeze
    CONNECTING_TEXTS = {
      'Comment' => 'upvoted your comment on',
      'Recommendation' => 'upvoted your',
    }.freeze

    verb 'upvote'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target { |event| event.subject&.subject }
    connecting_text { |_receiver_id, _vote, target| CONNECTING_TEXTS[target.class.name] || 'upvoted' }

    notify_user_ids do |_event, target, _actor|
      return [] unless ALLOWED_TARGET_TYPES.include? target.class

      user_ids = []
      user_ids << target.user_id if target.user_id.present?
      user_ids += target.maker_ids if target.is_a? Post
      user_ids
    end
  end
end
