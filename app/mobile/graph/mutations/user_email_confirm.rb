# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserEmailConfirm < BaseMutation
    argument :token, String, required: true

    require_current_user

    returns Mobile::Graph::Types::ViewerType

    def perform(token:)
      result = Subscribers.verify_by_token(
        token: token,
        user: current_user,
      )

      if result.is_a? Symbol
        error :base, result
      else
        current_user.reload
      end
    end
  end
end
