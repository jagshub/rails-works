# frozen_string_literal: true

module SignIn
  module ValidUsername
    extend self

    VALID_USERNAME_REGEXP = /^[A-Za-z0-9_]{1,30}$/.freeze
    RESERVED_USERNAMES = %w(deleted_user).freeze

    def call(username, auth_response: nil, existing_user: nil)
      return false if username.blank?
      return true if existing_user && existing_user.username == username
      return false if User.find_by_username(username).present?
      return false unless acceptable_name?(username)

      check_verified_user(username, auth_response)
    end

    private

    def check_verified_user(username, auth_response)
      verified_user = TwitterVerifiedUser.find_by_username(username)
      verified_user.nil? || verified_username_allowed?(verified_user, auth_response)
    end

    def acceptable_name?(username)
      VALID_USERNAME_REGEXP.match(username).present? && !RESERVED_USERNAMES.include?(username.downcase)
    end

    def verified_username_allowed?(verified_user, auth_response)
      auth_response.present? && verified_user.twitter_uid == auth_response.user_params[:twitter_uid]
    end
  end
end
