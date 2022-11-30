# frozen_string_literal: true

class Graph::Resolvers::Users::HasFollowed < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false unless current_user

    FollowedLoader.for(current_user).load(object)
  end

  class FollowedLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(users)
      followed_user_ids = @user.user_friend_associations.where(following_user_id: users.map(&:id)).pluck(:following_user_id)
      users.each do |user|
        fulfill user, followed_user_ids.include?(user.id)
      end
    end
  end
end
