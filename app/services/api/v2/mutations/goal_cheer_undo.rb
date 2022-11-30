# frozen_string_literal: true

module API::V2::Mutations
  class GoalCheerUndo < BaseMutation
    description 'Cheer a Goal as Viewer. Returns the cheered Goal'

    argument_record :goal, Goal, description: 'ID of the Goal to cheer.'

    returns API::V2::Types::GoalType

    def perform(goal:)
      ::Voting.destroy(subject: goal, user: current_user)
      goal
    end
  end
end
