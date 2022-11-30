# frozen_string_literal: true

require 'search_object/plugin/graphql'

class Graph::Resolvers::BaseSearch < Graph::Resolvers::Base
  include SearchObject.module(:graphql)

  def resolve(args = {})
    resolve_with_support(args[:filters].to_h)
  end

  private

  def current_user
    @current_user ||= context[:current_user]
  end
end
