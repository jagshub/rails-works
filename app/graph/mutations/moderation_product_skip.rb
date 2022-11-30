# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductSkip < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate

    argument :message, String, required: false

    returns Graph::Types::ProductType

    def perform(product:, message:)
      skip = ModerationSkip.find_or_initialize_by(subject: product, user: current_user)
      skip.update!(message: message)

      product
    end
  end
end
