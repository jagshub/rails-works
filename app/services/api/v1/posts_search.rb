# frozen_string_literal: true

class API::V1::PostsSearch
  include SearchObject.module
  include API::V1::Sorting
  include API::V1::Errors

  scope { Post.with_preloads_for_api.featured }

  option(:slug)
  option(:user_id)
  option(:maker_id) { |scope, value| scope.joins(:product_makers).where('product_makers.user_id' => value) }
  option(:url)      { |scope, value| scope.having_url Utf8Sanitize.call(value) }
  option(:featured_year) { |scope, value| scope.where('extract(year from featured_at) = ?', validate_int(:featured_year, value)) }
  option(:featured_month) { |scope, value| scope.where('extract(month from featured_at) = ?', validate_int(:featured_month, value)) }
  option(:featured_day) { |scope, value| scope.where('extract(day from featured_at) = ?', validate_int(:featured_day, value)) }

  option :topic, with: :apply_topic_filter
  option :category, with: :apply_topic_filter
  option :ios_featured_page, with: :apply_ios_feature_page_filter

  sort_by :id, :created_at, :updated_at, :featured_at, votes_count: :credible_votes_count

  private

  def apply_ios_feature_page_filter(scope, _days_ago)
    # NOTE(rstankov): This feature was disabled, but we still have to support filtering
    scope.none
  end

  def apply_topic_filter(scope, value)
    topic = Topic.friendly.find value
    scope.in_topic topic if topic
  end

  def validate_int(field_name, n)
    return if n.nil?

    Integer(n)
  rescue ArgumentError, TypeError
    raise InvalidInput.new(field_name.to_s => 'must be a number')
  end
end
