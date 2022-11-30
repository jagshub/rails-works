# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::Edition < Graph::Resolvers::Base
  argument :year, Int, required: true

  type Graph::Types::GoldenKittyEditionType, null: true

  def resolve(year:)
    GoldenKitty::Edition.where(year: year).first
  end
end
