# frozen_string_literal: true

module Graph::Types
  class ExternalModerationType < BaseObject
    field :take_next_product,
          ProductType,
          null: true,
          resolver: Graph::Resolvers::Moderation::TakeNextProductResolver
  end
end
