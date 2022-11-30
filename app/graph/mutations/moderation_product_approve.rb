# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductApprove < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate

    argument :message, String, required: false

    returns Graph::Types::ProductType

    def perform(product:, message:)
      ModerationLog.create!(moderator: current_user,
                            reference: product,
                            message: ModerationLog::REVIEWED_MESSAGE,
                            reason: message)
      product.update!(reviewed: true)

      product
    end
  end
end
