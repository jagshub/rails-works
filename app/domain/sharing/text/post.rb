# frozen_string_literal: true

module Sharing::Text::Post
  extend self

  def call(post)
    maker_twitters = post.makers.where.not(twitter_username: nil).pluck(:twitter_username)
    hunter_twitter = post.user&.twitter_username

    if hunter_twitter.in?(maker_twitters)
      # then the hunter is a maker, let's focus only on them as a maker:
      maker_twitter = hunter_twitter
      hunter_twitter = nil
    else
      maker_twitter = maker_twitters.first
    end

    Twitter::Message
      .new
      .add_mandatory(post.name)
      .add_optional(": #{ post.tagline }", if: post.tagline.present?, leading_space: false)
      .add_mandatory(Routes.post_url(post))
      .add_optional("by @#{ maker_twitter } h/t @#{ hunter_twitter } for hunting!",
                    if: maker_twitter.present? && hunter_twitter.present? && maker_twitter != hunter_twitter)
      .add_optional("by @#{ maker_twitter }",
                    if: maker_twitter.present? && (hunter_twitter.blank? || maker_twitter == hunter_twitter))
      .add_optional("via @#{ hunter_twitter }",
                    if: maker_twitter.blank? && hunter_twitter.present?)
      .add_optional('via @producthunt',
                    if: maker_twitter.blank? && hunter_twitter.blank?)
      .to_s
  end
end
