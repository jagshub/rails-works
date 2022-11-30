# frozen_string_literal: true

module Mobile::Graph::Utils
  class CanResolver
    class Can < Mobile::Graph::Resolvers::BaseResolver
      type Boolean, null: false

      def ability
        raise NoMethodError, 'ability missing'
      end

      def subject
        object
      end

      def resolve
        ApplicationPolicy.can? current_user, ability, subject
      end
    end

    def self.build(can, &block)
      klass = Class.new(Can) do
        define_method('ability') { can }

        define_method('subject') { block.call(object) } if block.present?
      end

      klass
    end
  end
end
