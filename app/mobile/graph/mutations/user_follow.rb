# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserFollow < BaseMutation
    argument_record :user, User, required: true
    argument :source_component, String, required: false

    returns Mobile::Graph::Types::UserType

    authorize :create, UserFriendAssociation

    def perform(user:, source_component: nil)
      Following.follow(
        user: current_user,
        follows: user,
        source: Mobile::ExtractInfoFromHeaders.get_mobile_source(context[:request]),
        source_component: source_component,
        request_info: request_info,
      )

      user.reload
    end
  end
end
