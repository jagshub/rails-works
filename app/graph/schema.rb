# frozen_string_literal: true

class Graph::Schema < GraphQL::Schema
  tracer(Graph::Utils::Tracer) if Rails.application.config.graphql_trace_enabled

  query Graph::Query
  mutation Graph::Mutation

  lazy_resolve Promise, :sync

  use GraphQL::Batch

  use GraphQL::Tracing::NewRelicTracing, set_transaction_name: true

  max_depth 20

  max_complexity 500_000

  default_max_page_size 100

  context_class Graph::Context

  disable_introspection_entry_points unless Config.graphiql_enabled?

  connections.add(Search::Query::Base, Search::Query::Base::Connection)
  connections.add(Graph::Resolvers::BrowserExtension::Feed::Resolver, Graph::Resolvers::BrowserExtension::Feed::Connection)
  connections.add(Graph::Resolvers::Comments::RepliesResolver::WrappedComment, Graph::Resolvers::Comments::RepliesResolver::RepliesConnection)
  connections.add(UpcomingPages::FetchActivities, Graph::Resolvers::UpcomingPages::ActivitiesResolver::Connection)
  connections.add(ActiveRecord::Relation, GraphQL::Pagination::ActiveRecordRelationConnection)
  connections.add(Reviews::SuggestedProducts, Graph::Utils::PaginatedCollectionConnection)
  connections.add(Graph::Resolvers::Moderation::TeamClaimsResolver::TeamClaimsFetcher, Graph::Utils::PaginatedCollectionConnection)

  def self.resolve_type(_type, object, _context)
    Graph::Utils::ResolveType.call(object)
  end
end
