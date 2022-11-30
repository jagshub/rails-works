# frozen_string_literal: true

class TwitterApi::Client
  attr_reader :api_client
  attr_reader :token

  class << self
    def for_user(user)
      new(user)
    end
  end

  def initialize(user = nil)
    @user = user
    find_new_token!
  end

  def friend_uids(start_page = nil)
    return unless @user.present? && @user.twitter_username.present?

    related_uids_for_username(:friend_ids, @user.twitter_username, start_page)
  end

  def follower_uids(start_page = nil)
    return unless @user.present? && @user.twitter_username.present?

    related_uids_for_username(:follower_ids, @user.twitter_username, start_page)
  end

  # Note(AR): api_method = :friend_ids | :follower_ids
  def related_uids_for_username(api_method, username, start_page = nil)
    results = []
    page = start_page

    loop do
      cursor = fetch_page(api_method, username, page)
      results += cursor.attrs[:ids]
      break if cursor.send(:last?)

      page = cursor.send(:next_cursor)
    end

    results
  end

  # Unfortunately there is no easy way to access the actual rate limit here right now, so we trust
  # https://dev.twitter.com/rest/reference/get/users/lookup and use it with a safety margin of 10%
  USERS_LOOKUP_RATE_LIMIT = (180 * 0.9).to_i

  def uids_to_uid_and_username(all_uids)
    uids_and_usernames = []
    requests_with_token = 0

    all_uids.each_slice(Twitter::REST::Users::MAX_USERS_PER_REQUEST) do |uids|
      requests_with_token += 1

      begin
        uids_and_usernames += @api_client.users(uids).map { |u| [u.id, u.screen_name] }
      rescue Twitter::Error::TooManyRequests, Twitter::Error::Forbidden
        find_new_token!
        requests_with_token = 0
      end

      if requests_with_token > USERS_LOOKUP_RATE_LIMIT
        find_new_token!
        requests_with_token = 0
      end
    end

    uids_and_usernames
  end

  def user_info(username)
    @api_client.user(username)
  rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
    nil
  end

  private

  def fetch_page(api_method, username, page)
    @api_client.public_send(api_method, username, cursor: page)
  rescue Twitter::Error::TooManyRequests
    find_new_token!
    @api_client.public_send(api_method, username, cursor: page)
  rescue Twitter::Error::Unauthorized, Twitter::Error::InternalServerError
    OpenStruct.new(attrs: { ids: [] }, last?: true)
  end

  def client_from_token(token)
    Twitter::REST::Client.new do |c|
      c.consumer_key        = Config.secret(:twitter_key)
      c.consumer_secret     = Config.secret(:twitter_secret)
      c.access_token        = token.token
      c.access_token_secret = token.secret
    end
  end

  def find_new_token!
    retries ||= 5
    @token = TwitterApi::AcquireToken.call(@user)
    @api_client = client_from_token(@token)
    @api_client.verify_credentials(skip_status: true)
  rescue Twitter::Error::Forbidden, Twitter::Error::Unauthorized, Twitter::Error::BadRequest, Twitter::Error::NotFound, Twitter::Error::InternalServerError
    @token.invalidate_temporarily!
    (retries -= 1) > 0 ? retry : raise
  end
end
