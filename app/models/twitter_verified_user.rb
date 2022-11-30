# frozen_string_literal: true

# == Schema Information
#
# Table name: twitter_verified_users
#
#  id               :integer          not null, primary key
#  twitter_uid      :text
#  twitter_username :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_twitter_verified_users_on_twitter_uid  (twitter_uid) UNIQUE
#  twitter_verified_users_lower_idx             (lower(twitter_username))
#

class TwitterVerifiedUser < ApplicationRecord
  class << self
    def find_by_username(username)
      find_by('lower(twitter_username) = ?', username.downcase)
    end

    def verified?(user)
      return false unless user.twitter_username?

      where('lower(twitter_username) = ?', user.twitter_username.downcase).exists?
    end
  end
end
