# frozen_string_literal: true

class Notifications::Helpers::DefaultValues::BaseValues
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def thumbnail_url
    raise NotImplementedError
  end

  def weblink_url
    raise NotImplementedError
  end

  def deeplink_uri
    MetaTags::MobileAppUrl.perform(object)
  end
end
