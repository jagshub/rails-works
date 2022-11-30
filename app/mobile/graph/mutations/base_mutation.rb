# frozen_string_literal: true

class Mobile::Graph::Mutations::BaseMutation < Graph::Utils::Mutation
  field :errors, [Mobile::Graph::Types::ErrorType], null: false
end
