# frozen_string_literal: true

module Graph::Types
  class Notifications::FeedItemType < BaseNode
    graphql_name 'NotificationFeedItem'

    class VerbEnum < BaseEnum
      graphql_name 'NotificationFeedItemVerbEnum'

      Stream::FeedItem::VERB_TO_EMOJI.keys.each do |verb|
        value verb.underscore, verb
      end
    end

    field :verb, VerbEnum, null: false
    field :last_occurrence_at, Graph::Types::DateTimeType, null: false
    field :seen_at, Graph::Types::DateTimeType, null: true
    field :connecting_text, String, null: false
    field :actors, resolver: Graph::Resolvers::Notifications::ActorsResolver
    field :context, Graph::Types::JsonType, null: false, resolver_method: :resolve_context
    field :target, Graph::Types::JsonType, null: false
    field :target_instance, Graph::Types::Notifications::FeedItemTargetType, null: true
    field :action_instance, Graph::Types::Notifications::FeedItemTargetType, null: true
    field :interactions, Graph::Types::JsonType, null: true

    field :comment, Graph::Types::CommentType, null: true

    def verb
      object.verb.underscore
    end

    def target
      object.data['target']
    end

    def resolve_context
      object.data['context']
    end

    def comment
      return TargetInstanceLoader.for.load(context) if object.verb == 'comment'

      nil
    end

    def action_instance
      data_context = object.data['context'] || {}
      id = data_context['id']
      type = data_context['type']
      return if id.blank? || type.blank?

      TargetInstanceLoader.for.load('id' => id, 'type' => type)
    end

    def target_instance
      TargetInstanceLoader.for.load(target) if target.present?
    end

    class TargetInstanceLoader < GraphQL::Batch::Loader
      def perform(targets)
        targets = targets.select do |target|
          klass = target['type']
          id = target['id']

          if id.present? && %w(Post Discussion::Thread Comment Review).include?(klass)
            true
          else
            fulfill(target, nil)
            false
          end
        end

        groups = targets.group_by { |t| t['type'] }
        groups.keys.each do |klass|
          group = groups[klass]

          klass.safe_constantize.where(id: group.pluck('id')).each do |instance|
            target = group.find { |t| t['id'] == instance.id }
            if target.present?
              fulfill(target, instance)
              targets = targets.reject { |t| t == target }
            end
          end
        end

        targets.each do |target|
          fulfill(target, nil)
        end
      end
    end
  end
end
