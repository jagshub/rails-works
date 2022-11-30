# frozen_string_literal: true

module API::V2Internal::Utils::ResolveType
  extend self

  def call(_type, obj, _ctx)
    from_class(obj.class)
  end

  def from_class(klass)
    return klass.graph_v2_internal_type if klass.respond_to?(:graph_v2_internal_type)

    type = "::API::V2Internal::Types::#{ klass }Type".safe_constantize
    return type unless type.nil?

    raise ArgumentError, "Cannot resolve type for class #{ klass.name }"
  end
end
