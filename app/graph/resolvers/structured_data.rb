# frozen_string_literal: true

class Graph::Resolvers::StructuredData < Graph::Resolvers::Base
  type Graph::Types::JsonType, null: true

  def resolve
    ::StructuredData::Generator.generator_for(object)
  end
end
