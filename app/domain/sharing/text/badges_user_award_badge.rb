# frozen_string_literal: true

module Sharing::Text::BadgesUserAwardBadge
  extend self

  def call(badge)
    Twitter::Message
      .new
      .add_mandatory(message(badge))
      .add_mandatory(Routes.profile_badges_url(badge.subject))
      .to_s
  end

  def message(badge)
    "I just earned the #{ badge.award.name } badge. Check out the rest of my "\
    'profile on @producthunt'
  end
end
