# frozen_string_literal: true

module Stream
  class Activities::ReviewCreated < Activities::Base
    ALLOWED_TARGET_TYPES = [Post, Product].freeze
    verb 'review'
    create_when :new_object

    target { |event| event.subject&.product || event.subject&.subject }

    connecting_text do |_, _, _|
      Stream::FeedItem::REVIEWED
    end

    notify_user_ids do |_event, target, _actor|
      return [] unless ALLOWED_TARGET_TYPES.include? target.class

      target&.maker_ids || []
    end
  end
end
