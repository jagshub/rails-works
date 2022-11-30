# frozen_string_literal: true

class Graph::Resolvers::Moderation::SeoStructuredDataValidationResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::Seo::StructuredData::ValidationMessageType.connection_type, null: false

  scope { SeoStructuredDataValidationMessages.all }

  class SubjectFilterType < Graph::Types::BaseEnum
    graphql_name 'SeoStructuredDataValidationSubjectKind'

    value 'Post'
    value 'ProductRequest'
    value 'Story'
  end

  option :kind, type: SubjectFilterType

  private

  def apply_kind_with_post(scope)
    scope.where(subject_type: 'Post')
  end

  def apply_kind_with_product_request(scope)
    scope.where(subject_type: 'ProductRequest')
  end

  def apply_kind_with_story(scope)
    scope.where(subject_type: 'Story')
  end
end
