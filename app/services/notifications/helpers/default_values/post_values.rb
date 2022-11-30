# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::PostValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Sharing.image_for(object)
  end

  def weblink_url
    Routes.post_url(object)
  end
end
