# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::CollectionValues < Notifications::Helpers::DefaultValues::BaseValues
  def thumbnail_url
    Screenshot.new(weblink_url).image_url
  end

  def weblink_url
    Routes.collection_url(object)
  end
end
