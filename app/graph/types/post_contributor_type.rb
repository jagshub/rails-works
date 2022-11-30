# frozen_string_literal: true

module Graph::Types
  class PostContributorRoleType < BaseEnum
    graphql_name 'PostContributorRole'

    value 'hunter'
    value 'maker'
    value 'hunter_and_maker'
    value 'commenter'
    value 'upvoter'
  end

  class PostContributorType < BaseObject
    field :role, PostContributorRoleType, null: false
    field :user, UserType, null: false
  end
end
