# frozen_string_literal: true

module API::V2Internal::Resolvers
  class Posts::IsLaunchDayResolver < API::V2Internal::Resolvers::BaseResolver
    type Boolean, null: false

    def resolve
      user = current_user
      return false if user.blank?

      user.admin? || object.user_id == user.id || ProductMakers.maker_of?(user: user, post_id: object.id)
    end
  end
end
