# frozen_string_literal: true

module API::V2::Resolvers
  module FindByIdResolver
    extend self

    def for(model_class)
      resolver_class = Class.new(BaseResolver) do
        argument :id, GraphQL::Types::ID, 'ID for the object.', required: true

        def resolve(id: nil)
          self.class.model_class.find_by(id: id)
        end
      end

      resolver_class.class_eval do
        @model_class = model_class

        def self.model_class
          @model_class
        end
      end

      resolver_class
    end
  end
end
