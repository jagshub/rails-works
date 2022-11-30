# frozen_string_literal: true

class Graph::Resolvers::FounderClub::Plan < Graph::Resolvers::Base
  argument :code, String, required: false

  type Graph::Types::FounderClubPlanType, null: false

  def resolve(code: nil)
    FounderClub.plan(discount_code: code)
  end
end
