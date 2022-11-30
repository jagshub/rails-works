# frozen_string_literal: true

module API::V2::Mutations
  class GoalCheer < BaseMutation
    description 'Cheer a Goal as Viewer. Returns the cheered Goal'

    argument_record :goal, Goal, description: 'ID of the Goal to cheer.'

    returns API::V2::Types::GoalType

    def perform(goal:)
      ::Voting.create(
        subject: goal,
        source: :api,
        user: current_user,
        request_info: request_info.merge(oauth_application_id: current_application.id),
      )

      goal
    end
  end
end
