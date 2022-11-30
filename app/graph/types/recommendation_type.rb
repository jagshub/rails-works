# frozen_string_literal: true

module Graph::Types
  class RecommendationType < BaseObject
    graphql_name 'Recommendation'

    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType
    implements Graph::Types::VotableInterfaceType

    field :id, ID, null: false
    field :body, String, null: false
    field :created_at, Graph::Types::DateTimeType, null: false
    field :edited_at, Graph::Types::DateTimeType, null: true
    field :is_disclosed, Boolean, method: :disclosed, null: false
    field :is_highlighted, Boolean, method: :highlighted, null: false
    field :body_html, String, null: false
    field :path, String, null: false

    association :recommended_product, Graph::Types::RecommendedProductType, null: false
    association :user, Graph::Types::UserType, null: false

    def body_html
      BetterFormatter.call(object.body, mode: :simple_with_usernames)
    end

    def path
      Routes.recommendation_path(object)
    end
  end
end
