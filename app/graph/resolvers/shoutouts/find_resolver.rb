# frozen_string_literal: true

class Graph::Resolvers::Shoutouts::FindResolver < Graph::Resolvers::Base
  type Graph::Types::ShoutoutType, null: true

  argument :id, ID, required: false

  def resolve(id: nil)
    return unless id

    Shoutout.not_trashed.find_by(id: id)
  end
end
