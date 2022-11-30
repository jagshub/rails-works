# frozen_string_literal: true

module Sharing::Text::UpcomingPage
  extend self

  MAX_NAME_LENGTH = 90

  def call(upcoming_page)
    Twitter::Message
      .new
      .add_mandatory("I just subscribed to #{ upcoming_page.name.truncate(MAX_NAME_LENGTH) }. Check it out 👉")
      .add_mandatory(Routes.upcoming_url(upcoming_page))
      .add_optional("via @#{ upcoming_page.user.twitter_username }", if: upcoming_page.user.twitter_username.present?)
      .to_s
  end
end
