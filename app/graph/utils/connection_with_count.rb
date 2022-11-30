# frozen_string_literal: true

module Graph::Utils::ConnectionWithCount
  extend self

  def build(type)
    type.define_connection do
      name "#{ type.name }ConnectionWithCount"

      field :count do
        type Integer
        resolve Graph::Utils::ConnectionWithCount::Resolver
      end
    end
  end

  module Resolver
    extend self

    def call(obj, _args, _ctx)
      obj.nodes.count
    end
  end
end
