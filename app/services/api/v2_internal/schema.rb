# frozen_string_literal: true

class API::V2Internal::Schema < GraphQL::Schema
  query API::V2Internal::Query
  mutation API::V2Internal::Mutation

  disable_introspection_entry_points unless Config.graphiql_enabled?

  lazy_resolve Promise, :sync

  use GraphQL::Batch

  use GraphQL::Tracing::NewRelicTracing

  default_max_page_size 20

  max_complexity 500_000

  connections.add(Search::Query::Base, Search::Query::Base::Connection)
  connections.add(ActiveRecord::Relation, GraphQL::Pagination::ActiveRecordRelationConnection)

  def self.id_from_object(object, _type, _ctx)
    API::V2Internal::IdFromObject.call(object)
  end

  def self.object_from_id(object, _type, ctx)
    API::V2Internal::ObjectFromId.call(object, ctx)
  end

  def self.resolve_type(type, object, context)
    API::V2Internal::Utils::ResolveType.call(type, object, context)
  end
end
