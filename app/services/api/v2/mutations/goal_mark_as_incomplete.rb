# frozen_string_literal: true

module API::V2::Mutations
  class GoalMarkAsIncomplete < BaseMutation
    description 'Marks a Goal as incomplete. Returns the updated Goal.'

    argument_record :goal, Goal, authorize: :update, description: 'ID of the Goal to mark complete.'

    spam_users_not_allowed

    returns API::V2::Types::GoalType

    def perform(goal:)
      goal.mark_as_incomplete! if goal.completed_at.present?

      goal
    end
  end
end
