# frozen_string_literal: true

# NOTE(dhruvparmar372): Non nullable connections.
#  Taken from: https://github.com/rmosolgo/graphql-ruby/issues/1217#issuecomment-422884621
module API::V2::Types
  class BaseObject < GraphQL::Schema::Object
    connection_type_class BaseConnection
    edge_type_class BaseEdge

    field_class API::V2::Types::BaseField

    delegate :current_user, :private_scope_allowed?, :url_tracking_params, to: :context

    def self.association(name, type, description: nil, null:, preload: nil, complexity: 2, include_id_field: false)
      field name, type, description: description, resolver: ::Graph::Utils::AssociationResolver.call(preload: preload || name, type: type, null: null), complexity: complexity
      field "#{ name }_id".to_sym, ID, description: "ID of #{ description }", null: null if include_id_field
    end
  end
end
