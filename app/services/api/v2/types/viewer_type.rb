# frozen_string_literal: true

module API::V2::Types
  class ViewerType < BaseObject
    description 'Top level scope for the user in whose context the API is running.'

    field :user, UserType, 'User who is the viewer of the API.', null: false

    field :goals, GoalType.connection_type, 'Look up goals of the viewer.', null: false, resolver: API::V2::Resolvers::Viewer::GoalsResolver
    field :maker_groups, MakerGroupType.connection_type, 'Look up maker groups the viewer is accepted member of.', null: false, method: :maker_group
    field :maker_projects, MakerProjectType.connection_type, 'Look up maker projects the viewer is a maintainer(either created or maintained by) of.', null: false, resolver_method: :maker_projects

    def user
      object
    end

    def maker_group
      []
    end

    def maker_projects
      []
    end
  end
end
