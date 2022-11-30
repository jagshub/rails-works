# frozen_string_literal: true

module Graph::Types
  class Products::ReviewSummaryType < BaseObject
    graphql_name 'ProductReviewSummary'

    field :id, ID, null: false
    field :start_date, DateType, null: false
    field :end_date, DateType, null: false
    field :period_in_days, Integer, null: false
    field :rating, Float, null: false
    field :reviews_count, Integer, null: false
    field :reviewers_count, Integer, null: false

    field :reviewers,
          Graph::Types::UserType.connection_type,
          max_page_size: 20,
          connection: true,
          null: false

    field :positive_tags,
          Graph::Types::Reviews::TagType.connection_type,
          max_page_size: 20,
          connection: true,
          null: false

    def reviewers
      object.reviewers_for_feed(current_user: context[:current_user])
    end

    def positive_tags
      object.positive_tags_for_feed
    end

    def period_in_days
      end_date - start_date
    end
  end
end
