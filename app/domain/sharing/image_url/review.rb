# frozen_string_literal: true

module Sharing::ImageUrl::Review
  def self.call(review)
    Users::Avatar.url_for_user(review.user, size: 120)
  end
end
