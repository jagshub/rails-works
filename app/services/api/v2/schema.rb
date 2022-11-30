# frozen_string_literal: true

module API::V2
  class Schema < GraphQL::Schema
    default_max_page_size 20

    max_depth((Rails.configuration.settings.api_v2_max_depth || 13).to_i)

    max_complexity((Rails.configuration.settings.api_v2_max_complexity || 500_000).to_i)

    query Types::QueryType

    mutation Types::MutationType

    context_class BaseContext

    lazy_resolve Promise, :sync

    use GraphQL::Batch

    use GraphQL::Tracing::NewRelicTracing

    query_analyzer API::V2::Utils::ComplexityAnalyzer
    query_analyzer API::V2::Utils::LogQueryDepth

    connections.add(ActiveRecord::Relation, GraphQL::Pagination::ActiveRecordRelationConnection)

    def self.resolve_type(*args)
      Graph::Utils::ResolveType.call(*args)
    end

    def self.id_from_object(*args)
      Graph::Utils::IdFromObject.call(*args)
    end

    def self.object_from_id(*args)
      Graph::Utils::ObjectFromId.call(*args)
    end
  end
end
