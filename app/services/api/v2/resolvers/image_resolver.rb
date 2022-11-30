# frozen_string_literal: true

module API::V2::Resolvers
  module ImageResolver
    extend self

    def generate(null: false, &block)
      resolver_class = Class.new(BaseResolver) do
        argument :width, GraphQL::Types::Int, required: false
        argument :height, GraphQL::Types::Int, required: false

        def resolve(width: nil, height: nil)
          image_uuid = self.class.resolve_block.call(object)
          Image.call(image_uuid, width: width, height: height)
        rescue NoMethodError
          nil
        end
      end

      resolver_class.class_eval do
        type String, null: null

        @resolve_block = block

        def self.resolve_block
          @resolve_block
        end
      end

      resolver_class
    end
  end
end
