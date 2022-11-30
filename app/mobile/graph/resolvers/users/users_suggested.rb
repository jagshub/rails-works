# frozen_string_literal: true

class Mobile::Graph::Resolvers::Users::UsersSuggested < Mobile::Graph::Resolvers::BaseResolver
  type [Mobile::Graph::Types::UserType], null: false

  argument :count, Int, required: false, default_value: 10
  argument :last_shown, [ID], required: false, default_value: []

  def resolve(count:, last_shown:)
    SuggestedUsers.for_user(current_user, count: count, last_shown: last_shown)
  end
end
