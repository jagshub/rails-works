# frozen_string_literal: true

class API::V1::FollowersSearch
  include SearchObject.module
  include API::V1::Sorting

  scope { UserFriendAssociation }

  sort_by :id, :created_at, :updated_at
  option(:following_user_id) { |scope, value| scope.where(following_user_id: value).with_follower_preloads }
  option(:follower_user_id) { |scope, value| scope.where(followed_by_user_id: value).with_following_preloads }
end
