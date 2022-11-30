# frozen_string_literal: true

module Mobile::Graph::Types
  class BaseObject < GraphQL::Schema::Object
    connection_type_class BaseConnection
    edge_type_class BaseEdge

    field_class BaseField

    class << self
      def association(name, type, description: '', null:, preload: nil, method: nil, deprecation_reason: nil)
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

        field name, description: description, resolver: resolver, deprecation_reason: deprecation_reason
      end
    end
  end

  def current_user
    context[:current_user]
  end
end
