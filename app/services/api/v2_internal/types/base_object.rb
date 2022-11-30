# frozen_string_literal: true

module API::V2Internal::Types
  class BaseObject < GraphQL::Schema::Object
    connection_type_class API::V2Internal::Types::BaseConnection
    edge_type_class API::V2Internal::Types::BaseEdge

    field_class API::V2Internal::Types::BaseField

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

        field name, description: description, resolver: resolver
      end
    end
  end
end
