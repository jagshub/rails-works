# frozen_string_literal: true

class Graph::Resolvers::MetaTags < Graph::Resolvers::Base
  type Graph::Types::MetaTagsType, null: false

  def resolve
    MetaTags::Generator.generator_for(object)
  end
end
