# frozen_string_literal: true

module Mobile::Graph::Utils::ResolveType
  extend self

  def call(_type, obj, _ctx)
    from_class(obj.class)
  end

  def from_class(klass)
    return klass.mobile_graphql_type if klass.respond_to?(:mobile_graphql_type)

    return Mobile::Graph::Types::Ads::ChannelType if klass == Ads::Ad

    type = "::Mobile::Graph::Types::#{ klass }Type".safe_constantize
    return type unless type.nil?

    raise ArgumentError, "Cannot resolve type for class #{ klass.name }"
  end
end
