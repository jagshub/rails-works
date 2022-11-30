# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class IsFollowed < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(users)
      followers = @user.followers.where(id: users).pluck(:id)

      users.each do |user|
        fulfill user, followers.include?(user.id)
      end
    end
  end
end
