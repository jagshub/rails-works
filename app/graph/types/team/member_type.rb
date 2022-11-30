# frozen_string_literal: true

module Graph::Types
  class Team::MemberType < BaseNode
    graphql_name 'TeamMember'

    field :role, Graph::Types::Team::MemberRoleEnum, null: false
    field :status, Graph::Types::Team::MemberStatusEnum, null: false
    field :position, String, null: true
    field :team_email, String, null: true

    association :user, Graph::Types::UserType, null: false
    association :product, Graph::Types::ProductType, null: false
  end
end
