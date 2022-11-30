# frozen_string_literal: true

module Sharing::Text::AnthologiesStory
  extend self

  def call(story)
    Twitter::Message
      .new
      .add_mandatory(story.title.to_s)
      .add_mandatory(Routes.story_url(story))
      .add_optional(mention_author(story))
      .to_s
  end

  def mention_author(story)
    # Note(Raj): A story could have a non-ph author. This should be mentioned first.
    return "by #{ story.author_name }" if story.author_name.present?

    return "@#{ story.author.twitter_username }" if story.author&.twitter_username
  end
end
