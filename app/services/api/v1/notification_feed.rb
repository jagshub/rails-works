# frozen_string_literal: true

module API::V1::NotificationFeed
  extend self

  def feed_for(_user, _limit, _offset, _include_types = nil)
    []
  end
end
