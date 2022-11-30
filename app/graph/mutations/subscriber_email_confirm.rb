# frozen_string_literal: true

module Graph::Mutations
  class SubscriberEmailConfirm < BaseMutation
    argument :token, String, required: true

    require_current_user

    field :viewer, Graph::Types::ViewerType, null: true

    def perform(token:)
      result = Subscribers.verify_by_token(
        token: token,
        user: current_user,
      )

      if result.is_a? Symbol
        error :base, result
      else
        { viewer: current_user.reload }
      end
    end
  end
end
