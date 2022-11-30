# frozen_string_literal: true

module Graph::Types
  class Seo::StructuredData::ValidationMessageType < BaseObject
    graphql_name 'SeoStructuredDataValidationMessage'

    field :id, ID, null: false
    field :messages, [String], null: false
    field :subject, Seo::StructuredData::ValidationSubjectType, null: false
  end
end
