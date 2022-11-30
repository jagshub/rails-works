# frozen_string_literal: true

# == Schema Information
#
# Table name: disabled_friend_syncs
#
#  id                  :integer          not null, primary key
#  followed_by_user_id :integer          not null
#  following_user_id   :integer          not null
#
# Indexes
#
#  index_disabled_friend_syncs_on_following_user_id  (following_user_id)
#  index_disabled_twitter_sync_followed_following    (followed_by_user_id,following_user_id) UNIQUE
#
# Foreign Keys
#
#  disabled_twitter_syncs_followed_by_user_id_fk  (followed_by_user_id => users.id) ON DELETE => cascade
#  disabled_twitter_syncs_following_user_id_fk    (following_user_id => users.id) ON DELETE => cascade
#

module FriendSync
  class Disabled < ApplicationRecord
    self.table_name = 'disabled_friend_syncs'

    class << self
      # The people who user manually unfollowed
      def for_friends_of(user)
        where(followed_by_user: user).pluck(:following_user_id)
      end

      # The people who manually unfollowed user
      def for_followers_of(user)
        where(following_user: user).pluck(:followed_by_user_id)
      end
    end

    belongs_to :followed_by_user, class_name: 'User'
    belongs_to :following_user,   class_name: 'User'

    validates :followed_by_user, uniqueness: { scope: :following_user }
  end
end
