# frozen_string_literal: true

module Mobile::Graph::Mutations
  class ProductMute < BaseMutation
    argument_record :product, Product, required: true

    returns Mobile::Graph::Types::ProductType

    require_current_user

    def perform(product:)
      ::Subscribe.mute(product, current_user)

      product
    end
  end
end
