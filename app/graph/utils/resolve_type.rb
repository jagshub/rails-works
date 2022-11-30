# frozen_string_literal: true

module Graph::Utils::ResolveType
  extend self

  class UnknownTypeError < ArgumentError
    def initialize(klass)
      super "Cannot resolve type for class #{ klass.name }"
    end
  end

  def call(obj)
    from_class(obj.class)
  end

  def from_class(klass)
    return klass.graphql_type if klass.respond_to? :graphql_type

    return Graph::Types::Ads::ChannelType if klass == Ads::Ad

    type = "::Graph::Types::#{ klass }Type".safe_constantize
    return type unless type.nil?

    raise UnknownTypeError, klass
  end
end
