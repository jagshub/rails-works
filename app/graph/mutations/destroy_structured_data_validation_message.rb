# frozen_string_literal: true

module Graph::Mutations
  class DestroyStructuredDataValidationMessage < BaseMutation
    argument_record :message, SeoStructuredDataValidationMessages, required: true

    returns Graph::Types::Seo::StructuredData::ValidationMessageType

    def perform(message:)
      message.destroy!
      message
    end
  end
end
