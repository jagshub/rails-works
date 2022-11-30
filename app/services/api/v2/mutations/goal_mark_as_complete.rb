# frozen_string_literal: true

module API::V2::Mutations
  class GoalMarkAsComplete < BaseMutation
    description 'Marks a Goal as complete. Returns the updated Goal'

    argument_record :goal, Goal, authorize: :update, description: 'ID of the goal to mark complete.'

    spam_users_not_allowed

    returns API::V2::Types::GoalType

    def perform(goal:)
      goal.mark_as_complete! if goal.completed_at.blank?

      goal
    end
  end
end
