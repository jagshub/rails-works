# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::VoteValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Users::Avatar.url_for_user(object.user, size: 256)
  end

  def weblink_url
    Routes.subject_url(object.subject)
  end
end
