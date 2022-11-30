# frozen_string_literal: true

module FriendSync
  module Connections
    class Twitter
      def initialize(user)
        @friend_ids = []
        @follower_ids = []

        return if user.twitter_username.blank?

        twitter_client = TwitterApi::Client.for_user(user)
        friend_uids    = twitter_client.friend_uids.map(&:to_s)
        follower_uids  = twitter_client.follower_uids.map(&:to_s)

        @friend_ids   = User.visible.where(twitter_uid: friend_uids).pluck(:id)
        @follower_ids = User.visible.where(twitter_uid: follower_uids).pluck(:id)
      rescue ::Twitter::Error::NotFound, ::Twitter::Error::Forbidden, ::Twitter::Error::ServiceUnavailable, HTTP::ConnectionError
        nil # Retry at next run
      end

      attr_reader :friend_ids, :follower_ids
    end
  end
end
