# frozen_string_literal: true

class API::V2Internal::Resolvers::IsFollowingResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    IsFollowingLoader.for(current_user).load(object)
  end

  class IsFollowingLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(users)
      followed_ids = UserFriendAssociation.where(followed_by_user_id: @user.id, following_user_id: users.map(&:id)).pluck(:following_user_id)

      users.each do |user|
        fulfill user, followed_ids.include?(user.id)
      end
    end
  end
end
