# frozen_string_literal: true

class Graph::Resolvers::Moderation::SeoPostsResolver < Graph::Resolvers::BaseSearch
  type Graph::Types::PostType.connection_type, null: false

  scope { Post.featured.by_featured_at }

  class DescriptionFilterType < Graph::Types::BaseEnum
    graphql_name 'PostDescriptionFilter'

    value 'WITHOUT_DESCRIPTION'
    value 'SHORT_DESCRIPTION'
    value 'LONG_DESCRIPTION'
  end

  option :description_filter, type: DescriptionFilterType

  option :keyword_suggestion, type: Boolean, with: :apply_keyword_suggestion

  private

  def apply_description_filter_with_without_description(scope)
    scope.without_desciption
  end

  def apply_description_filter_with_short_description(scope)
    scope.with_short_description
  end

  def apply_description_filter_with_long_description(scope)
    scope.with_long_description
  end

  def apply_keyword_suggestion(scope, value)
    return unless value

    SeoQuery.with_keywords(ModerationLog.exclude_moderated(scope, ModerationLog::SEO_MODERATED_MESSAGE))
  end
end
