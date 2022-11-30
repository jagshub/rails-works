# frozen_string_literal: true

class Mobile::Graph::Resolvers::Comments::BodyHTML < Mobile::Graph::Resolvers::BaseResolver
  type String, null: false

  def resolve
    BetterFormatter.call(object.body, mode: :full).gsub('?makers', '<a>?makers</a>').gsub("\n", '<br />')
  end
end
