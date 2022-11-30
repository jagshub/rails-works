# frozen_string_literal: true

module Graph::Types
  class ProductRequestType < BaseObject
    graphql_name 'ProductRequest'

    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType
    implements Graph::Types::TopicableInterfaceType

    field :id, ID, null: false
    field :body, String, null: true
    field :created_at, Graph::Types::DateTimeType, null: false
    field :edited_at, Graph::Types::DateTimeType, null: true
    field :featured_at, Graph::Types::DateTimeType, null: true
    field :is_advice, Boolean, method: :advice?, null: false
    field :is_hidden, Boolean, method: :hidden?, null: false
    field :recommended_products_count, Int, null: false
    field :related_product_requests_count, Int, null: false
    field :seo_description, String, null: true
    field :seo_title, String, null: true
    field :title, String, null: false
    field :body_html, String, null: true
    field :path, String, null: false
    field :user, Graph::Types::UserType, resolver: Graph::Resolvers::ProductRequests::UserResolver, null: true
    field :recommended_products, Graph::Types::RecommendedProductType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::ProductRequests::RecommendedProductsResolver, null: false, connection: true
    field :related_product_requests, Graph::Types::ProductRequestType.connection_type, max_page_size: 20, null: false, connection: true
    field :related_product_request_suggestions, Graph::Types::ProductRequestType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::ProductRequests::RelatedProductRequestSuggestionsResolver, null: false, connection: true

    association :duplicate_of, Graph::Types::ProductRequestType, null: true

    def body_html
      BetterFormatter.call(object.body, mode: :simple_with_usernames)
    end

    def path
      Routes.product_request_path(object)
    end
  end
end
