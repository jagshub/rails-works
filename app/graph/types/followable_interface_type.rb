# frozen_string_literal: true

module Graph::Types
  module FollowableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Followable'

    field :followers_count, Int, null: false

    # NOTE(rstankov): Temporary disable, until we find a faster solution
    # resolve ->(obj, _args, ctx) { ctx[:current_user] ? obj.followers.order_by_friends(ctx[:current_user]) : obj.followers }
    field :followers, Graph::Types::UserType.connection_type, max_page_size: 20, connection: true, null: false
  end
end
