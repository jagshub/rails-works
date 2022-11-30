# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::UserValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Users::Avatar.url_for_user(object, size: 80)
  end

  def weblink_url
    Routes.profile_url(object.username)
  end
end
