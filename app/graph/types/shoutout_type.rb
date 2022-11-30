# frozen_string_literal: true

module Graph::Types
  class ShoutoutType < BaseNode
    implements VotableInterfaceType

    field :body, Graph::Types::HtmlContentType, null: false
    field :created_at, DateTimeType, null: false
    field :year, Int, null: false

    association :user, UserType, null: false
    association :mentioned_users, [UserType], null: false
  end
end
