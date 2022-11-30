# frozen_string_literal: true

class ProductMakers::SendTweetWorker < ApplicationJob
  include ActiveJobRetriesCount
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandleTwitterErrors
  include ActiveJobHandlePostgresErrors

  def perform(username, post)
    return unless post.visible?

    maker = ProductMakers::Maker.new(username: username, post: post)
    ProductMakers::SendTweet.call(maker: maker)
  end
end
