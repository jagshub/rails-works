# frozen_string_literal: true

module API::V2::Types
  class MutationType < BaseObject
    def self.mutation_field(mutation_class)
      field mutation_class.name.demodulize.underscore, mutation: mutation_class, complexity: 50
    end

    mutation_field API::V2::Mutations::GoalCheer
    mutation_field API::V2::Mutations::GoalCheerUndo
    mutation_field API::V2::Mutations::GoalCreate
    mutation_field API::V2::Mutations::GoalMarkAsComplete
    mutation_field API::V2::Mutations::GoalMarkAsIncomplete
    mutation_field API::V2::Mutations::GoalUpdate

    mutation_field API::V2::Mutations::UserFollow
    mutation_field API::V2::Mutations::UserFollowUndo
  end
end
