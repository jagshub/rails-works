# frozen_string_literal: true

module Graph::Types
  module Graph::Types::ReviewableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Reviewable'

    field :id, ID, null: false
    field :name, String, null: false
    field :reviews_count, Int, null: false
    field :reviews_with_body_count, Int, null: false
    field :reviewers, Graph::Types::UserType.connection_type, max_page_size: 20, connection: true, null: false
    field :can_create, resolver: Graph::Resolvers::Can.build(:create) { |obj| Review.new(subject: obj) }
    field :viewer_review, Graph::Types::ReviewType, null: true
    field :reviews_rating, Float, null: true
    field :is_maker, Boolean, null: false
    field :reviews, Graph::Types::ReviewType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Reviews, null: false, connection: true
    field :review_tags, [Graph::Types::Reviews::TagType], null: false
    field :reviews_with_rating_count, Int, null: false
    field :rating_specific_count, [Graph::Types::Reviews::RatingSpecificType], null: false

    def review_tags
      ReviewTag.all
    end

    def viewer_review
      return if context[:current_user].blank?

      object.reviews.where(user: context[:current_user]).first
    end

    def is_maker
      current_user = context[:current_user]
      return false if current_user.blank?

      if object.is_a?(Product)
        object.makers.pluck(:id).include?(current_user&.id)
      else
        ProductMakers.maker_of?(user: current_user, post_id: object.id)
      end
    end

    def rating_specific_count
      Posts::ReviewRating.rating_specific_count(object)
    end
  end
end
