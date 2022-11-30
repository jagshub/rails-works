# frozen_string_literal: true

module Graph::Mutations
  class SlackBotDestroy < BaseMutation
    returns Graph::Types::ViewerType

    def perform
      SlackBot.deactivate(current_user)
      current_user
    end
  end
end
