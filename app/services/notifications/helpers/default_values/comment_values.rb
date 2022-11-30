# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::CommentValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Users::Avatar.url_for_user(object.user, size: 80)
  end

  def weblink_url
    Routes.comment_url(object)
  end
end
