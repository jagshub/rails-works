# frozen_string_literal: true

module Moderation::Notifier::UrlHelper
  def link_to(text_or_object, url = nil)
    "<#{ url.present? ? url_for(url) : url_for(text_or_object) }|#{ text_for(text_or_object) }>"
  end

  private

  def url_for(object)
    case object
    when Post then Routes.post_url(object)
    when User then Routes.profile_url(object.username)
    when ProductMakers::Maker then "https://twitter.com/#{ object.twitter_username }"
    else object.to_s
    end
  end

  def text_for(object)
    case object
    when Post then object.name
    when User, ProductMakers::Maker then "@#{ object.username }"
    else object.to_s
    end
  end
end
