# frozen_string_literal: true

module TwitterApi::ValidateScreenName
  extend self

  def call(username)
    return false if username.blank?

    info = TwitterApi::Client.new.user_info(username)
    return false if info.blank?

    NormalizeTwitter.username(info.screen_name) == NormalizeTwitter.username(username)
  end
end
