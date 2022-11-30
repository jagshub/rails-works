# frozen_string_literal: true

class FriendSync::Worker < ApplicationJob
  include ActiveJobHandleNetworkErrors
  include ActiveJobHandlePostgresErrors

  rescue_from TwitterApi::OutOfTokensError, Twitter::Error::TooManyRequests, Twitter::Error::InternalServerError, Twitter::Error::Unauthorized do
    # We're temporarily out of tokens, ignore.
  end

  def perform(user_id)
    @user = User.find(user_id)

    connections = [FriendSync::Connections::Twitter.new(@user), FriendSync::Connections::Facebook.new(@user)]

    add_follower_ids = find_follower_ids(connections.flat_map(&:follower_ids).uniq)
    add_friend_ids, remove_friend_ids = find_friends_ids(connections.flat_map(&:friend_ids).uniq)

    add_friend_ids.each do |friend_id|
      HandleRaceCondition.call(ignore: true, max_retries: 0) do
        @user.user_friend_associations.create! following_user_id: friend_id
      end
    end

    @user.user_friend_associations.where(following_user_id: remove_friend_ids).destroy_all if remove_friend_ids.any?

    add_follower_ids.each do |follower_id|
      HandleRaceCondition.call(ignore: true, max_retries: 0) do
        @user.user_follower_associations.create! followed_by_user_id: follower_id
      end
    end

    @user.update! last_friend_sync_at: Time.current

    notify_newly_followed_users(add_friend_ids)
  end

  private

  def find_friends_ids(new_ids)
    old_ids = @user.friend_ids

    disabled_sync_friend_ids = FriendSync::Disabled.for_friends_of(@user)

    add_friend_ids    = new_ids - old_ids - disabled_sync_friend_ids - [@user.id]
    remove_friend_ids = old_ids - new_ids - disabled_sync_friend_ids

    [add_friend_ids, remove_friend_ids]
  end

  def find_follower_ids(new_ids)
    old_ids = @user.follower_ids

    disabled_sync_follower_ids = FriendSync::Disabled.for_followers_of(@user)

    # NOTE(rstankov): We want to keep followers on PH, even when they unfollow elsewhere
    new_ids - old_ids - disabled_sync_follower_ids - [@user.id]
  end

  # Note (rstankov): We only notify users followed by the synced user
  # The goal is not to spam, newly registered users with new follower notifications
  def notify_newly_followed_users(add_friend_ids)
    return if add_friend_ids.blank?

    UserFriendAssociation.where(following_user_id: add_friend_ids, followed_by_user_id: @user.id).find_each do |assoc|
      Notifications.notify_about kind: 'new_follower', object: assoc
      Stream::Events::UserFriendAssociationCreated.trigger(
        user: @user,
        subject: assoc,
        source: :application,
      )
    end
  end
end
