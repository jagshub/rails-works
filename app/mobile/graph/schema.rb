# frozen_string_literal: true

class Mobile::Graph::Schema < GraphQL::Schema
  query Mobile::Graph::Query
  mutation Mobile::Graph::Mutation
  context_class Mobile::Graph::Context

  disable_introspection_entry_points unless Config.graphiql_enabled?

  lazy_resolve Promise, :sync

  use GraphQL::Batch

  use GraphQL::Tracing::NewRelicTracing

  max_complexity 3_000_000

  default_max_page_size 100

  connections.add(Mobile::Graph::Resolvers::Comments::Replies::WrappedComment, Mobile::Graph::Resolvers::Comments::Replies::RepliesConnection)
  connections.add(Search::Query::Base, Search::Query::Base::Connection)
  connections.add(ActiveRecord::Relation, GraphQL::Pagination::ActiveRecordRelationConnection)

  def self.id_from_object(object, _type, _ctx)
    Mobile::Graph::IdFromObject.call(object)
  end

  def self.object_from_id(object, _type, ctx)
    Mobile::Graph::ObjectFromId.call(object, ctx)
  end

  def self.resolve_type(type, object, context)
    Mobile::Graph::Utils::ResolveType.call(type, object, context)
  end
end
