# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::LinkResolver < Graph::Resolvers::Base
    type String, null: true

    def self.build(kind)
      ::Graph::Utils::AssociationResolver.call(
        preload: :links,
        type: String,
        null: true,
        handler: ->(links) { links.detect { |link| link.kind == kind }&.url },
      )
    end

    def resolve(**args)
      resolver.call(object, args, context)
    end

    def model_class
      raise NotImplementedError
    end
  end
end
