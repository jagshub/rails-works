# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::HallOfFameResolver < Graph::Resolvers::Base
  argument :year, Int, required: false

  type Graph::Types::GoldenKittyHallOfFameType, null: false

  def resolve(year: nil)
    GoldenKitty.hof_resolver_data(year)
  end
end
