# frozen_string_literal: true

module Sharing::Text::Topic
  extend self

  def call(topic)
    "Check out the #{ topic.name } topic on @ProductHunt #{ Routes.topic_url(topic) }"
  end
end
