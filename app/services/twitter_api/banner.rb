# frozen_string_literal: true

module TwitterApi::Banner
  extend self

  def call(user)
    client = TwitterApi::Client.new(user)
    user_info = client.user_info(user.twitter_username)

    return if user_info.blank?
    return unless user_info.profile_banner_url_https?

    banner_url = user_info.profile_banner_url_https('1500x500').to_s

    return if Faraday.head(banner_url).status == 404

    banner_url
  rescue Faraday::TimeoutError, Faraday::SSLError, Faraday::ConnectionFailed
    # NOTE(rstankov) network issues
    nil
  rescue Twitter::Error::Forbidden
    # NOTE(ayrton) user has been suspended
    nil
  end
end
