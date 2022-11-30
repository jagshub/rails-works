# frozen_string_literal: true

module API::V1::Feed
  extend self

  def feed_for(_user)
    ::API::V1::Feed::Parser.new.parse([])
  end
end
