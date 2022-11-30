# frozen_string_literal: true

module API::V2::Resolvers
  module SlugOrIdResolver
    extend self

    def for(model_class)
      resolver_class = Class.new(BaseResolver) do
        argument :id, GraphQL::Types::ID, 'ID for the object.', required: false
        argument :slug, GraphQL::Types::String, 'URL friendly slug for the object.', required: false

        def resolve(id: nil, slug: nil)
          self.class.model_class.friendly.find id || slug
        rescue ActiveRecord::RecordNotFound
          nil
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
