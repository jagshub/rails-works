# frozen_string_literal: true

module API::V2::Mutations
  class GoalCreate < BaseMutation
    description 'Create a Goal for Viewer. Returns the created Goal.'

    argument :project_id, GraphQL::Types::ID, 'ID of the MakerProject', required: false

    argument_record :group, MakerGroup, authorize: :read, required: false, description: 'ID of the MakerGroup(space) to set on the Goal. Viewer should be accepted member of the MakerGroup.'

    argument :due_at, API::V2::Types::DateTimeType, 'Set the date and time when the Goal is due in future. Pass null to make Goal never due.', required: false
    argument :title, GraphQL::Types::String, "Set the title of the Goal. Accepts a non empty string. Maximum length is #{ Goal::TITLE_MAX_LENGTH } characters.", required: true

    spam_users_not_allowed

    returns API::V2::Types::GoalType

    def perform(**args)
      inputs = sanitize_inputs(args.slice(:due_at, :title, :group, :project))

      return error :title, "Goal title is too long. (maximum is #{ Goal::TITLE_MAX_LENGTH } characters)" if inputs[:title].length > Goal::TITLE_MAX_LENGTH

      create_main_group_membership inputs[:group]

      inputs = inputs.merge(
        user: current_user,
        source: ::HasApiActions.source_to_identifier(current_application),
      )

      Goal.create! inputs unless inputs.empty?
    end

    private

    def sanitize_inputs(inputs)
      inputs[:title] = Sanitizers::HtmlToText.call(inputs[:title])

      # NOTE(Dhruv): Default to MakerGroup.main group if group_id was not passed via arguments or was passed as nil.
      inputs[:group] = inputs.key?(:group) && inputs[:group].present? ? inputs[:group] : MakerGroup.main

      inputs
    end

    def create_main_group_membership(group)
      # NOTE(Dhruv): Create default group membership for user when creating goal if not already present
      MakerGroupMember.create!(user: current_user, group: MakerGroup.main) if group == MakerGroup.main && MakerGroupMember.where(user: current_user, group: MakerGroup.main).none?
    end
  end
end
