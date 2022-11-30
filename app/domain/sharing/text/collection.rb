# frozen_string_literal: true

module Sharing::Text::Collection
  extend self

  def call(collection)
    Twitter::Message
      .new
      .add_mandatory(collection.name)
      .add_optional(": #{ collection.title }", leading_space: false, if: collection.title.present?)
      .add_mandatory("by @#{ collection.user.twitter_username }", if: !collection.without_curator? && collection.user.twitter_username)
      .add_mandatory('on @ProductHunt')
      .add_mandatory(Routes.collection_url(collection))
      .to_s
  end
end
