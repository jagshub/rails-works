# frozen_string_literal: true

class Graph::Mutations::BaseMutation < Graph::Utils::Mutation
  field :errors, [Graph::Types::ErrorType], null: false
end
