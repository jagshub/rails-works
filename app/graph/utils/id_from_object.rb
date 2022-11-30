# frozen_string_literal: true

module Graph::Utils::IdFromObject
  extend self

  def call(object, _definition = nil, _ctx = nil)
    GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
  end
end
