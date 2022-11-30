# frozen_string_literal: true

module Following
  extend self

  FOLLOWS_HOURLY_LIMIT = 100

  def follow(user:, follows:, source:, source_component: nil, request_info: {})
    check_for_follow_limit_hourly(user)
    create_disabled_sync_entry(user, follows)
    follow_user(user, follows, source: source, source_component: source_component, request_info: request_info)
  end

  def unfollow(user:, unfollows:)
    create_disabled_sync_entry(user, unfollows)
    unfollow_user(user, unfollows)
  end

  def bulk_follow(user:, following:, source:, source_component: nil, request_info: {})
    check_for_follow_limit_hourly(user)
    following.each do |to_follow|
      follow(user: user, follows: to_follow, source: source, source_component: source_component, request_info: request_info)
    end
  end

  def bulk_unfollow(user:, unfollowing:)
    unfollowing.each do |to_unfollow|
      unfollow(user: user, unfollows: to_unfollow)
    end
  end

  private

  def follow_user(user, follows, source:, source_component: nil, request_info: {})
    HandleRaceCondition.call do
      assoc = UserFriendAssociation.find_by(followed_by_user: user, following_user: follows)
      return assoc if assoc.present?

      assoc = UserFriendAssociation.create!(
        followed_by_user: user,
        following_user: follows,
        source: source_from_request_info(request_info),
        source_component: source_component,
      )

      Notifications.notify_about(kind: 'new_follower', object: assoc)

      Stream::Events::UserFriendAssociationCreated.trigger(
        user: user,
        subject: assoc,
        source: source,
        request_info: request_info,
      )

      data_fields = {
        follower_name: user.name,
        follower_profile_pic: user.image,
      }

      Iterable.trigger_event('new_follower', email: user.email, user_id: user.id, data_fields: data_fields)

      assoc
    end
  end

  def unfollow_user(user, unfollows)
    assoc = UserFriendAssociation.find_by(followed_by_user: user, following_user: unfollows)
    return if assoc.blank?

    assoc.destroy
  end

  def create_disabled_sync_entry(user, other_user)
    HandleRaceCondition.call do
      FriendSync::Disabled.find_or_create_by!(followed_by_user: user, following_user: other_user)
    end
  end

  def source_from_request_info(request_info)
    return if request_info.blank?

    ::HasApiActions.source_to_identifier(OAuth::Application.find(request_info[:oauth_application_id]))
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def check_for_follow_limit_hourly(user)
    return unless Features.enabled?(:user_follow_limiter, user)
    return if user.blank?

    follows_count = UserFriendAssociation.where(followed_by_user_id: user.id).where('created_at > ?', 1.hour.ago).count
    raise KittyPolicy::AccessDenied if follows_count > FOLLOWS_HOURLY_LIMIT
  end
end
