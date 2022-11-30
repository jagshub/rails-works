# frozen_string_literal: true

module Graph::Mutations
  class PostDraftCreate < BaseMutation
    argument :url, String, required: true
    argument :product_id, ID, required: false
    argument :connect_product, Boolean, required: false

    returns Graph::Types::PostDraftType

    require_current_user

    def perform(url:, product_id: nil, connect_product: false)
      product = product_id.present? ? Product.find_by(id: product_id) : nil

      PostDraft.find_or_create_by(
        user: context[:current_user],
        url: url,
        post: nil,
        connect_product: connect_product,
        suggested_product: product,
      )
    end
  end
end
