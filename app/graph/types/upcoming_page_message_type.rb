# frozen_string_literal: true

module Graph::Types
  class UpcomingPageMessageType < BaseObject
    graphql_name 'UpcomingPageMessage'

    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :subject, String, null: false
    field :slug, String, null: false
    field :layout, String, null: false
    field :visibility, String, null: false
    field :body, Graph::Types::HTMLType, null: true
    field :created_at, Graph::Types::DateTimeType, null: false
    field :upcoming_page_survey_id, ID, null: true
    field :comments_count, Int, null: false
    field :sent_count, Int, null: false
    field :opened_count, Int, null: false
    field :clicked_count, Int, null: false
    field :failed_count, Int, null: false
    field :state, String, null: false
    field :kind, String, null: false
    field :subscriber_filters, null: false, resolver: Graph::Resolvers::UpcomingPages::SubscriberFiltersResolver, extras: [:path]
    field :is_draft, Boolean, method: :draft?, null: false
    field :is_public, Boolean, method: :publicly_accessible?, null: false
    field :conversations, [Graph::Types::UpcomingPageConversationType], null: false
    field :unseen_conversations_count, Int, null: false
    field :user, Graph::Types::UserType, null: false, method: :author
    field :conversations_count, Int, null: false
    field :recipients, Graph::Types::UserType.connection_type, null: true, max_page_size: 40, complexity: ->(_ctx, _args, child_complexity) { 2 * child_complexity }, resolver: Graph::Resolvers::UpcomingPages::MessageRecipientsResolver, connection: true

    field :deliveries, Graph::Types::UpcomingPageMessageDeliveryType.connection_type, resolver: Graph::Resolvers::UpcomingPages::DeliveriesResolver, null: false, connection: true

    association :upcoming_page, Graph::Types::UpcomingPageType, null: false
    association :survey, Graph::Types::UpcomingPageSurveyType, null: true
    association :post, Graph::Types::PostType, null: true

    def sent_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.sent_count
    end

    def opened_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.opened_count
    end

    def clicked_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.clicked_count
    end

    def failed_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.failed_count
    end

    def conversations
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.conversations.not_trashed
    end

    def conversations_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.conversations.not_trashed.count
    end

    def unseen_conversations_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.conversations.not_trashed.unseen.count
    end
  end
end
