# frozen_string_literal: true

class Posts::NotifyCompanyOnTwitterWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleTwitterErrors
  include ActiveJobHandlePostgresErrors

  def perform(post)
    return unless post.visible?
    return unless post.new_product&.twitter_url?

    twitter_handle = NormalizeTwitter.username(post.new_product.twitter_url)

    return unless TwitterApi::ValidateScreenName.call(twitter_handle)

    TwitterBot::ProductHuntHi.send_tweet(text: text_for(post, twitter_handle: twitter_handle))
  end

  private

  def text_for(post, twitter_handle:)
    Twitter::Message
      .new
      .add_mandatory("@#{ twitter_handle } FYI, #{ post.name } was posted on @ProductHunt")
      .add_mandatory(Routes.post_url(post))
      .add_mandatory('— Invite your teammates to join as Makers 🙌')
      .to_s
  end
end
