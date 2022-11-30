# frozen_string_literal: true

module MutualFriends
  extend self

  def to_html(first_user, second_user, tracking_params: nil)
    mutual_friend = find_mutual_friend(first_user, second_user)

    return '' unless mutual_friend

    "Followed by #{ link_to(mutual_friend, tracking_params) }#{ and_others(first_user) }"
  end

  private

  def find_mutual_friend(first_user, second_user)
    UserFriendAssociation.where(
      following_user_id: first_user.id,
      followed_by_user_id: UserFriendAssociation.where(followed_by_user_id: second_user.id).select(:following_user_id),
    ).order(id: :desc).first.try :followed_by_user
  end

  def link_to(user, tracking_params)
    %(<a href="#{ Routes.profile_url(user.username, tracking_params) }">#{ user.name }</a>)
  end

  def and_others(user)
    followers_count = user.follower_count - 1

    return '' if followers_count.zero?

    " and #{ followers_count } #{ 'other'.pluralize(followers_count) }"
  end
end
