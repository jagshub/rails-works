# frozen_string_literal: true

module FriendSync
  module Connections
    class Facebook
      def initialize(user)
        @mutual_friend_ids = []

        access_token = user.access_tokens.facebook.first
        return if access_token.blank?

        friends = FacebookApi::Friends.call access_token.token

        return if friends.blank?

        friend_uids = friends.map { |f| f['id'] }

        @mutual_friend_ids = User.visible.where(facebook_uid: friend_uids).pluck(:id)
      end

      def friend_ids
        @mutual_friend_ids
      end

      def follower_ids
        @mutual_friend_ids
      end
    end
  end
end
