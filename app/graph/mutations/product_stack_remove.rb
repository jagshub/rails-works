# frozen_string_literal: true

module Graph::Mutations
  class ProductStackRemove < BaseMutation
    argument_record :product, Product, required: true

    returns Graph::Types::Products::StackType

    require_current_user

    def perform(product:)
      ::Stacks.remove(product: product, user: current_user)
    end
  end
end
