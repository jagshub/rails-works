# frozen_string_literal: true

# == Schema Information
#
# Table name: user_friend_associations
#
#  id                  :integer          not null, primary key
#  followed_by_user_id :integer          not null
#  following_user_id   :integer          not null
#  created_at          :datetime
#  source              :string
#  source_component    :string
#
# Indexes
#
#  index_user_friend_associations_on_created_and_followed_by  (created_at,followed_by_user_id)
#  index_user_friend_associations_on_following_user_id        (following_user_id)
#  index_user_friend_associations_on_source                   (source) WHERE (source IS NOT NULL)
#  index_user_friend_assocs_followed_following                (followed_by_user_id,following_user_id) UNIQUE
#
# Foreign Keys
#
#  user_friend_associations_followed_by_user_id_fk  (followed_by_user_id => users.id)
#  user_friend_associations_following_user_id_fk    (following_user_id => users.id)
#

class UserFriendAssociation < ApplicationRecord
  extension HasApiActions

  belongs_to :followed_by_user, class_name: 'User', inverse_of: :user_friend_associations, counter_cache: :friend_count
  belongs_to :following_user,   class_name: 'User', inverse_of: :user_follower_associations, counter_cache: :follower_count

  validates :followed_by_user, uniqueness: { scope: :following_user }
  validate :user_is_not_the_same

  scope :with_follower_preloads, -> { preload(:followed_by_user) }
  scope :with_following_preloads, -> { preload(:following_user) }

  class << self
    # Note(andreasklinger): UserFriendAssociation does not have update_at
    def collection_cache_key(collection, _timestamp_column)
      super(collection.presence || all, :created_at)
    end

    def apply_order_by_friends(model, column, user_or_id)
      user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id
      joins_sql = <<-SQL
        LEFT OUTER JOIN #{ table_name }
        #{ ActiveRecord::Base.sanitize_sql_for_conditions([
                                                            " ON #{ table_name }.following_user_id = #{ column }
                                                            AND #{ table_name }.followed_by_user_id = ?", user_id.to_i
                                                          ]) }
      SQL

      model.joins(joins_sql).order("#{ table_name }.following_user_id nulls last")
    end
  end

  private

  def user_is_not_the_same
    return unless followed_by_user == following_user

    errors.add(:base, 'Both users are the same person')
  end
end
