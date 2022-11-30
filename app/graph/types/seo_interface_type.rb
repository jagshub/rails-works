# frozen_string_literal: true

module Graph::Types
  module SeoInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'SEOInterface'

    field :id, ID, null: false
    field :structured_data, resolver: Graph::Resolvers::StructuredData
    field :meta, resolver: Graph::Resolvers::MetaTags
  end
end
