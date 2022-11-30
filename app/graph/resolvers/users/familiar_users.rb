# frozen_string_literal: true

class Graph::Resolvers::Users::FamiliarUsers < Graph::Resolvers::Base
  type [Graph::Types::UserType], null: false

  argument :count, Int, required: true

  def resolve(count:)
    count = [20, count].min

    # Note(DavidZhang): FamiliarUsers.to/2 can accept nil as current_user
    ::FamiliarUsers.to(current_user, count)
  end
end
