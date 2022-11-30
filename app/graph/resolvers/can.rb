# frozen_string_literal: true

module Graph::Resolvers
  class Can < Graph::Resolvers::Base
    type Boolean, null: false

    attr_reader :ability

    def self.build(ability, &block)
      resolver_class = Class.new(self)
      resolver_class.define_method(:ability) { ability }
      resolver_class.define_method(:extract_subject) { block.call(object) } if block.present?

      resolver_class
    end

    def resolve
      ApplicationPolicy.can? current_user, ability, extract_subject
    end

    private

    def ability
      raise NotImplementedError
    end

    def extract_subject
      # just give back the object if no block provided
      object
    end
  end
end
