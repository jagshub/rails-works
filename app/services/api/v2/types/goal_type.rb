# frozen_string_literal: true

module API::V2::Types
  class GoalType < BaseObject
    description 'A goal created by maker.'

    field :id, ID, 'ID of the goal.', null: false
    field :completed_at, DateTimeType, 'Identifies the date and time when goal was marked as completed.', null: true
    field :created_at, DateTimeType, 'Identifies the date and time when goal was created.', null: false
    field :title, String, 'Title of the goal in plain text', null: false, method: :title_text
    field :due_at, DateTimeType, 'Identifies the date and time when goal is due.', null: true
    field :current, Boolean, "Whether the goal is user's current goal or not.", null: false
    field :current_until, DateTimeType, "Identifies the date and time until the goal is user's current goal.", null: true
    field :url, String, 'Public URL of the goal.', null: false
    field :focused_duration, Integer, 'Total time spent in focus mode in seconds, starts at 0', null: false
    field :cheer_count, Integer, 'Number of cheers on the Goal.', null: false, method: :votes_count

    field :is_cheered, Boolean, 'Whether the Viewer has cheered the goal or not.', resolver: API::V2::Resolvers::Votes::IsVotedResolver, complexity: 2

    field :project, MakerProjectType, 'Maker project to which the goal belongs to.', null: true, method: :project

    association :group, MakerGroupType, description: 'Maker group to which the goal belongs to.', null: false, include_id_field: true

    association :user, UserType, description: 'User who created the goal.', null: false, include_id_field: true

    def url
      # NOTE(emilov): since goals have been removed the original route used here, user_goal_url, doesn't exist anymore.
      # Replace it with the root url so this method doesn't barf.
      Routes.root_url
    end

    def group_id
      object.maker_group_id
    end

    def project
      nil
    end

    def project_id
      nil
    end
  end
end
