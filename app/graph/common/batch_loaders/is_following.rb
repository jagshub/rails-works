# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class IsFollowing < GraphQL::Batch::Loader
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
