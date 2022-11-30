# frozen_string_literal: true

class Posts::UpvoteTweetWorker < ApplicationJob
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleTwitterErrors

  # Note(Mike Coutermarsh): When a post name is at the max length, it's too long to fit in a tweet
  #   with an image + url. So we must truncate it.
  MAX_POST_NAME_LENGTH = 50

  VOTE_TWEET_THRESHOLD = 100

  MESSAGE_TEMPLATES = [
    'Woohoo! %s was upvoted for the 100th time. 🙌',
    '%s was upvoted 100 times. Your parents would be proud 😄',
    '%s just reached 100 upvotes. 😻',
    '100 product hunters upvoted %s. Radical. 👊',
    'Welcome to the 100 upvote club for %s. 👯',
  ].freeze

  MESSAGE_GIFS = %w(
    batman-thumbs-up.gif
    dance-and-shake.gif
    diver.gif
    excited-oprah.gif
    fresh-five.gif
    happy-cat.gif
    jimmy-fallon.gif
    kanye-approves.gif
    khaled.gif
    lamborghini.gif
    leo-upvote.gif
    mind-blown.gif
    napoleon-dynamite.gif
    seinfeld-dance.gif
    shaq-wiggle.gif
    taylor-swift.gif
  ).freeze

  class << self
    def message_for_post(post)
      format(MESSAGE_TEMPLATES.sample, post.name.truncate(MAX_POST_NAME_LENGTH))
    end

    def send_tweet?(post)
      post.credible_votes_count == VOTE_TWEET_THRESHOLD && post.makers.present?
    end
  end

  def perform(vote)
    return unless vote.subject_type == 'Post'

    post = vote.subject
    return unless self.class.send_tweet?(post)

    post.makers.each do |maker|
      next if maker.twitter_username.blank?

      message = Twitter::Message
                .new
                .add_mandatory("@#{ maker.twitter_username } #{ self.class.message_for_post(post) } #{ Routes.post_url(post) }")
                .add_optional("\n\nAdd the badge to your site: #{ Routes.post_embed_url(post) }", leading_space: false)

      TwitterBot::ProductHuntHi.send_tweet(text: message, image_url: S3Helper.image_url(MESSAGE_GIFS.sample))
    end
  end
end
