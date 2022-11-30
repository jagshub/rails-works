# frozen_string_literal: true

module Graph::Resolvers
  class SlugOrId < Graph::Resolvers::Base
    argument :id, ID, required: false
    argument :slug, String, required: false

    attr_reader :type

    def self.build(model_class, type = nil)
      type ||= Graph::Utils::ResolveType.from_class(model_class)

      resolver_class = Class.new(self)
      resolver_class.type type, null: true
      resolver_class.define_method(:model_class) { model_class }
      resolver_class
    end

    def resolve(id: nil, slug: nil)
      model_class.friendly.find id || slug
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def model_class
      raise NotImplementedError
    end
  end
end
