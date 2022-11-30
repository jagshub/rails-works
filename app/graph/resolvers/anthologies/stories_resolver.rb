# frozen_string_literal: true

class Graph::Resolvers::Anthologies::StoriesResolver < Graph::Resolvers::BaseSearch
  scope { Anthologies::Story.published.preload(:author) }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'StoriesOrder'

    value 'NEWEST'
    value 'POPULAR'
    value 'TRENDING'
  end

  class CategoryType < Graph::Types::BaseEnum
    graphql_name 'StoriesCategory'

    Anthologies::Story.categories.keys.each do |category|
      value category
    end
  end

  option :order, type: OrderType, default: 'NEWEST'
  option :category, type: CategoryType
  # Note(Rahul): This is used for Stories index page to exclude featured story & featured section story
  option :exclude_featured, type: Boolean, with: :apply_exclude_featured
  option :query, type: String, with: :apply_query

  def apply_order_with_newest(scope)
    scope.by_newest
  end

  def apply_order_with_popular(scope)
    scope.by_popular
  end

  def apply_order_with_trending(scope)
    scope.by_trending
  end

  def apply_exclude_featured(scope, value)
    return scope unless value

    # Note(Rahul): Featured category is currently static & if it's moved to dynamic need to update this
    ids = scope.maker_stories.where(featured_position: nil).limit(4).pluck(:id)

    scope
      .where(featured_position: nil)
      .where.not(id: ids)
  end

  def apply_query(scope, query)
    return scope if query&.strip.blank?

    scope.where_like_slow(:title, query)
  end

  Anthologies::Story.categories.keys.each do |category|
    define_method("apply_category_with_#{ category }") do |scope|
      scope.where(category: category)
    end
  end
end
