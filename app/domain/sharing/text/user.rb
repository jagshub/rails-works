# frozen_string_literal: true

module Sharing::Text::User
  extend self

  def call(subject, user: nil)
    if subject == user
      "Check out my profile on @ProductHunt #{ Routes.profile_url(subject) }"
    else
      "Check out #{ subject.twitter_username ? '@' + subject.twitter_username : subject.name } on @ProductHunt #{ Routes.profile_url(subject) }"
    end
  end
end
