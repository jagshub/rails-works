# frozen_string_literal: true

module Sharing::Text::BadgesGoldenKittyAwardBadge
  extend self

  def call(badge)
    post = badge.subject

    "#{ post.name } is the #{ badge.category } on @ProductHunt for Golden Kitty #{ badge.year } #{ Routes.post_url(post) }"
  end
end
