class KittynewsSchema < GraphQL::Schema
  mutation Types::MutationType
  query Types::QueryType
  context_class Utils::Context
  # enable batch loading
  use BatchLoader::GraphQL
end
