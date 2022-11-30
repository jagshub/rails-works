# frozen_string_literal: true

class ProductMakers::SendTweet
  attr_reader :maker, :user, :post

  class << self
    def call(maker:)
      new(maker: maker).call
    end
  end

  def initialize(maker:)
    @maker = maker
    @user  = maker.user
    @post  = maker.post
  end

  def call
    return unless send_tweet?
    return unless valid_twitter_username?

    text = Twitter::Message
           .new
           .add_mandatory("@#{ maker.twitter_username } FYI, you've been added as a maker")
           .add_optional("of #{ post.name }")
           .add_optional('on @ProductHunt')
           .add_mandatory(Routes.post_url(post))
           .add_mandatory("h/t @#{ maker.invited_by&.twitter_username } 🙌", if: include_invited_by?)
           .to_s

    TwitterBot::ProductHuntHi.send_tweet(text: text)
  end

  private

  def include_invited_by?
    user != maker.invited_by && maker.invited_by.present? && maker.invited_by.twitter_username.present?
  end

  def valid_twitter_username?
    TwitterApi::ValidateScreenName.call(maker.twitter_username)
  end

  def send_tweet?
    !post.trashed? && !post.scheduled? && maker.twitter_username.present?
  end
end
