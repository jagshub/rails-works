# frozen_string_literal: true

module Sharing::Text::DiscussionThread
  extend self

  def call(discussion, user:)
    Twitter::Message
      .new
      .add_mandatory(message_beginning(discussion, user))
      .add_optional('on @producthunt')
      .add_mandatory("\"#{ discussion.title }\"")
      .add_optional('Share your thoughts:')
      .add_mandatory(Routes.discussion_url(discussion))
      .to_s
  end

  private

  def message_beginning(discussion, user)
    discussion_user = discussion.user

    return 'Check out my discussion' if discussion_user == user
    return "Check out @#{ discussion_user.twitter_username }'s discussion" if discussion_user.twitter_username.present?

    "Check out #{ discussion_user.name }'s discussion"
  end
end
