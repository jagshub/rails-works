# frozen_string_literal: true

module Graph::Types
  class Seo::StructuredData::ValidationSubjectType < BaseUnion
    graphql_name 'StructuredDataValidationSubject'

    possible_types(
      Graph::Types::PostType,
      Graph::Types::Anthologies::StoryType,
    )
  end
end
