# frozen_string_literal: true

module Sharing::Text::UpcomingEvent
  extend self

  def call(upcoming_event)
    maker_twitter = upcoming_event.user.twitter_username
    product = upcoming_event.product
    tagline = "is launching #{ product.posts_count > 0 ? 'something new' : 'for the first time' }"

    Twitter::Message
      .new
      .add_mandatory(product.name)
      .add_mandatory(tagline)
      .add_mandatory(Routes.product_url(product))
      .add_optional("by @#{ maker_twitter }", if: maker_twitter.present?)
      .add_optional('via @producthunt', if: maker_twitter.blank?)
      .to_s
  end
end
