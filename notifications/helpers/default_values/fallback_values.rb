# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::FallbackValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Screenshot.new(weblink_url).image_url
  end

  def weblink_url
    Routes.root_url
  end

  def deeplink_uri
    'producthunt://home'
  end
end
