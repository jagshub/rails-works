# frozen_string_literal: true

class Graph::Resolvers::Users::MadePostsSearchResolver < Graph::Resolvers::BaseSearch
  scope { object.products.visible.by_featured_at }

  option :featured, type: Boolean, with: :for_featured
  option :include_no_longer_available, type: Boolean, with: :for_no_longer_available
  option :posted_date, type: String, with: :with_posted_by_date
  option :query, type: String, with: :with_query

  private

  def for_featured(scope, value)
    return scope unless value

    scope.featured
  end

  def for_no_longer_available(scope, value)
    # NOTE(DZ): if true, return all posts
    return scope if value

    scope.alive
  end

  def with_posted_by_date(scope, value)
    return scope if value.blank?

    date_stamp = posted_date_to_timestamp(value)
    scope.for_date(date_stamp)
  end

  def posted_date_to_timestamp(posted_date)
    case posted_date
    when '30:days'
      30.days.ago
    when '90:days'
      90.days.ago
    when '12:months'
      12.months.ago
    end
  end

  def with_query(scope, query)
    return scope if query&.strip.blank?

    scope.where_like_slow(:name, query)
  end
end
