# frozen_string_literal: true

class Mobile::Graph::Mutations::ProductUnfollow < Mobile::Graph::Mutations::BaseMutation
  argument_record :product, Product, required: true

  returns Mobile::Graph::Types::ProductType

  require_current_user

  def perform(product:)
    ::Subscribe.unsubscribe(product, current_user)

    product.reload
  end
end
