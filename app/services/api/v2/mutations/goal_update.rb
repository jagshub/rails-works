# frozen_string_literal: true

module API::V2::Mutations
  class GoalUpdate < BaseMutation
    description "Update a Goal's `due_at`, `title`, `group` fields. Returns the updated Goal."

    argument_record :goal, Goal, authorize: :update, description: 'ID of the Goal to update.'

    argument_record :group, MakerGroup, authorize: :read, required: false, description: 'ID of the MakerGroup(space) to set on the Goal. Cannot be null. Viewer should be accepted member of the MakerGroup. '

    argument :due_at, API::V2::Types::DateTimeType, 'Set the date and time when the Goal is due in future. Pass null to make the Goal never due.', required: false
    argument :title, GraphQL::Types::String, "Set the title of the Goal. Accepts a non empty string. Maximum length is #{ Goal::TITLE_MAX_LENGTH } characters.", required: false

    argument :project_id, GraphQL::Types::ID, 'ID of the MakerProject', required: false

    spam_users_not_allowed

    returns API::V2::Types::GoalType

    def perform(goal:, **args)
      inputs = args.slice(:due_at, :title, :group)
      inputs[:title] = Sanitizers::HtmlToText.call(inputs[:title]) if inputs.key?(:title)

      return error :title, "Goal title is too long. (maximum is #{ Goal::TITLE_MAX_LENGTH } characters)" if inputs.key?(:title) && inputs[:title].length > Goal::TITLE_MAX_LENGTH

      goal.update! inputs unless inputs.empty?
      goal
    end
  end
end
