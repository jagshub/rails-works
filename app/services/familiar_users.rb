# frozen_string_literal: true

class FamiliarUsers
  attr_reader :user_scope, :current_user, :count, :exclude_ids, :popular_scope

  def self.call(**args)
    new(**args).call
  end

  def self.to(user, count = 10)
    call(
      user_scope: User,
      current_user: user,
      count: count,
      popular_scope: User.where('follower_count > 5000').with_preloads.non_admin.by_random,
    )
  end

  def initialize(user_scope:, current_user:, count:, exclude_ids: [], popular_scope: nil)
    @user_scope = user_scope
    @current_user = current_user
    @count = count
    @popular_scope = popular_scope
    @exclude_ids = exclude_ids
    @exclude_ids << current_user.id if current_user
  end

  def call
    return popular_users(count) if current_user.blank?

    users = familiar_users
    users += popular_users(count - users.size) if users.size < count
    users
  end

  private

  def familiar_users
    user_scope.credible.where(id: friend_ids - exclude_ids).by_follower_count.limit(count).distinct
  end

  def popular_users(limit)
    scope = popular_scope || user_scope.by_follower_count.distinct
    scope.credible.where.not(id: friend_ids + exclude_ids).limit(limit)
  end

  def friend_ids
    return [] if current_user.blank?

    current_user.user_friend_associations.pluck(:following_user_id)
  end
end
