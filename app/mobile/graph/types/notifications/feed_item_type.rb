# frozen_string_literal: true

module Mobile::Graph::Types
  class Notifications::FeedItemType < BaseNode
    graphql_name 'NotificationFeedItem'

    class VerbEnum < BaseEnum
      graphql_name 'NotificationFeedItemVerbEnum'

      Stream::FeedItem::VERB_TO_EMOJI.keys.each do |verb|
        value verb.underscore, verb
      end
    end

    field :verb, VerbEnum, null: false
    field :last_occurrence_at, Mobile::Graph::Types::DateTimeType, null: false
    field :seen_at, Mobile::Graph::Types::DateTimeType, null: true
    field :connecting_text, String, null: false
    field :actors, resolver: Mobile::Graph::Resolvers::Notifications::ActorsResolver
    field :target_instance, Mobile::Graph::Types::Notifications::FeedItemTargetType, null: true
    field :context, Mobile::Graph::Types::Notifications::ContextType, null: false, resolver_method: :resolve_context
    field :target, Mobile::Graph::Types::Notifications::TargetType, null: false
    field :interactions, Mobile::Graph::Types::JsonType, null: true

    field :comment, Mobile::Graph::Types::CommentType, null: true

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
      return Graph::Common::BatchLoaders::Notifications::Target.for.load(context) if object.verb == 'comment'

      nil
    end

    def target_instance
      Graph::Common::BatchLoaders::Notifications::Target.for.load(target) if target.present?
    end
  end
end
