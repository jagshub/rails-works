# frozen_string_literal: true

# Note(JL): This module is meant to be a short-lived sync for catching changes to website_url and twitter_username
# on the User model and syncing them to the new additional links feature for Profiles. We'll need to sync that
# data between both User and user links until the profile has fully launched. Once the new profile has launched,
# this module can be removed along with the website_url property on user.

module Users::LinkSync
  extend self

  # NOTE(DZ): Method assumes no links present for user. In case of url collision
  # between website_url and twitter_username, only a twitter link will be saved.
  def call(user)
    if user.twitter_username.present?
      url = "https://twitter.com/#{ user.twitter_username }"
      user.links.twitter.create!(name: 'Twitter', url: url)
    end

    return if user.website_url.blank?

    kind = Users::LinkKind.kind_from_url(user.website_url)
    if kind != 'twitter'
      user.links.create!(kind: kind, name: kind.titlecase, url: user.website_url)
    elsif user.links.twitter.find_by_url(user.website_url).blank?
      user.links.create!(name: 'Website', url: user.website_url)
    end
  end
end
