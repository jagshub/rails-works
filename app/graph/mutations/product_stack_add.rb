# frozen_string_literal: true

module Graph::Mutations
  class ProductStackAdd < BaseMutation
    argument_record :product, Product, required: true
    argument :source, String, required: true

    returns Graph::Types::Products::StackType

    require_current_user

    def perform(product:, source:)
      Stacks.add(product: product, user: current_user, source: source)
    end
  end
end
