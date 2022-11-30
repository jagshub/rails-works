# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductMarkAsOffline < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate

    returns Graph::Types::ProductType

    def perform(product:)
      ModerationLog.create!(moderator: current_user,
                            reference: product,
                            message: ModerationLog::OFFLINE)

      product.no_longer_online!

      product
    end
  end
end
