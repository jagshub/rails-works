# frozen_string_literal: true

module Graph::Types
  class BaseObject < GraphQL::Schema::Object
    connection_type_class Graph::Types::BaseConnection
    edge_type_class Graph::Types::BaseEdge

    field_class Graph::Types::BaseField

    class << self
      def association(name, type, description: '', null:, preload: nil, method: nil)
        handler = if method.blank?
                    nil
                  elsif method.is_a?(Symbol)
                    ->(assoc) { assoc.public_send(method) }
                  else
                    method
                  end

        resolver = ::Graph::Utils::AssociationResolver.call(
          preload: preload || name,
          type: type,
          null: null,
          handler: handler,
        )

        field name, type, description: description, resolver: resolver, null: null
      end
    end
  end
end
