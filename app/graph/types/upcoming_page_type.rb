# frozen_string_literal: true

module Graph::Types
  class UpcomingPageType < BaseObject
    graphql_name 'UpcomingPage'

    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::TopicableInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: true
    field :updated_at, Graph::Types::DateTimeType, null: true
    field :account_id, ID, method: :ship_account_id, null: false

    field :who_text, Graph::Types::HTMLType, null: true
    field :what_text, Graph::Types::HTMLType, null: true
    field :why_text, Graph::Types::HTMLType, null: true
    field :success_text, Graph::Types::HTMLType, null: true
    field :widget_intro_message, String, null: true

    field :logo_uuid, String, null: true
    field :background_image_uuid, String, null: true
    field :unsplash_background_url, String, null: true
    field :thumbnail_uuid, String, null: true
    field :subscriber_count, Int, null: false
    field :brand_color, String, null: true
    field :status, String, null: true
    field :seo_title, String, null: true
    field :seo_description, String, null: true
    field :seo_image_uuid, String, null: true
    field :inbox_email, String, null: false

    field :subscriber_id, resolver: Graph::Resolvers::UpcomingPages::SubscriberIdResolver
    field :unsubscriber_count, Int, null: false
    field :webhook_url, String, null: true
    field :variant, resolver: Graph::Resolvers::UpcomingPages::VariantResolver

    field :imported_subscriber_count, Int, null: false
    field :not_imported_subscriber_count, Int, null: false
    field :user_subscriber_count, Int, null: false
    field :sent_count, Int, null: false
    field :drafts_count, Int, null: false
    field :unseen_conversations_count, Int, null: false
    field :maker_subscriber_count, Int, null: false
    field :maker_task_count, Int, null: false
    field :maker_task_completed_count, Int, null: false
    field :is_subscribed, resolver: Graph::Resolvers::UpcomingPages::HasSubscribedResolver
    field :hiring, Boolean, null: true
    field :available_template_names, [String], null: false
    field :producthunt_url, String, null: true
    field :popular_subscribers, resolver: Graph::Resolvers::UpcomingPages::PopularSubscribersResolver
    field :subscribers, Graph::Types::UpcomingPageSubscriberConnection, max_page_size: 40, resolver: Graph::Resolvers::UpcomingPages::SubscribersResolver, null: false, connection: true
    field :segments, [Graph::Types::UpcomingPageSegmentType], null: false
    field :subscriber_searches, [Graph::Types::UpcomingPageSubscriberSearchType], null: false
    field :maker_tasks, [Graph::Types::UpcomingPageMakerTaskType], null: false

    field :subscriber_search, Graph::Types::UpcomingPageSubscriberSearchType, null: true do
      argument :id, ID, required: false
    end

    field :segment, Graph::Types::UpcomingPageSegmentType, null: true do
      argument :id, ID, required: true
    end

    field :subscriber_metrics, resolver: Graph::Resolvers::UpcomingPages::SubscriberMetricsResolver
    field :message_metrics, resolver: Graph::Resolvers::UpcomingPages::MessageMetricsResolver
    field :demographics_metrics, resolver: Graph::Resolvers::UpcomingPages::DemographicsMetricsResolver
    field :messages, Graph::Types::UpcomingPageMessageType.connection_type, resolver: Graph::Resolvers::UpcomingPages::MessagesResolver, null: false, connection: true
    field :conversations, Graph::Types::UpcomingPageConversationType.connection_type, null: false, connection: true
    field :activities, Graph::Types::UpcomingPageActivityType.connection_type, null: false, resolver: Graph::Resolvers::UpcomingPages::ActivitiesResolver, connection: true
    field :survey, resolver: Graph::Resolvers::UpcomingPages::SurveyResolver
    field :surveys, Graph::Types::UpcomingPageSurveyType.connection_type, null: false, max_page_size: 100, resolver: Graph::Resolvers::AuthorizationAssociation.build(:surveys), connection: true
    field :conversation, resolver: Graph::Resolvers::UpcomingPages::ConversationResolver

    field :website_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('website')
    field :app_store_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('app_store')
    field :play_store_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('play_store')
    field :facebook_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('facebook')
    field :twitter_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('twitter')
    field :angellist_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('angellist')
    field :privacy_policy_url, resolver: Graph::Resolvers::UpcomingPages::LinkResolver.build('privacy_policy')
    field :jobs_url, String, null: true

    field :message, Graph::Types::UpcomingPageMessageType, resolver: Graph::Resolvers::UpcomingPages::Message

    field :can_request_stripe_discount, Boolean, null: false
    field :ship, resolver: Graph::Resolvers::Ships::BillingResolver.build { |upcoming_page| upcoming_page.account.user }
    field :can_access_ship_premium_support, resolver: Graph::Resolvers::Can.build(:ship_premium_support)
    field :can_manage, resolver: Graph::Resolvers::Can.build(ApplicationPolicy::MAINTAIN)
    field :can_destroy, resolver: Graph::Resolvers::Can.build(:destroy)
    field :can_manage_email_form, resolver: Graph::Resolvers::Can.build(:ship_email_form)
    field :can_manage_ship_ab, resolver: Graph::Resolvers::Can.build(:ship_ab)
    field :can_manage_ship_metrics, resolver: Graph::Resolvers::Can.build(:ship_metrics)
    field :can_manage_ship_surveys, resolver: Graph::Resolvers::Can.build(:ship_surveys)
    field :can_manage_webhooks, resolver: Graph::Resolvers::Can.build(:ship_webhooks)
    field :can_new_upcoming_page_message, resolver: Graph::Resolvers::Can.build(:new) { |obj| UpcomingPageMessage.new upcoming_page: obj }
    field :can_send_continuous_messages, resolver: Graph::Resolvers::Can.build(:send_continuous_messages)
    field :can_new_upcoming_page_segment, resolver: Graph::Resolvers::Can.build(:ship_segments)
    field :can_promote_upcoming_page, resolver: Graph::Resolvers::Can.build(:promote)
    field :can_schedule_posts, resolver: Graph::Resolvers::Can.build(:ship_schedule_posts)
    field :can_claim_aws_credits, resolver: Graph::Resolvers::Can.build(:claim_aws_credits)

    association :variants, [Graph::Types::UpcomingPageVariantType], null: false
    association :user, Graph::Types::UserType, null: false
    association :account, Graph::Types::ShipAccountType, null: false

    def unsubscriber_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.subscribers.unsubscribed.count
    end

    def webhook_url
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.webhook_url
    end

    def imported_subscriber_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.confirmed_subscribers.imported.count
    end

    def not_imported_subscriber_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.confirmed_subscribers.not_imported.count
    end

    def user_subscriber_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.confirmed_subscribers.user.count
    end

    def sent_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.messages.sent.count
    end

    def drafts_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.messages.draft.count
    end

    def unseen_conversations_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.conversations.unseen.count
    end

    def maker_subscriber_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.confirmed_subscribers.maker.count
    end

    def maker_task_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.maker_tasks.count
    end

    def maker_task_completed_count
      return 0 unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.maker_tasks.completed.count
    end

    def available_template_names
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      ::UpcomingPageVariant::TEMPLATE_NAMES
    end

    def producthunt_url
      SafeExternalUrl.call('producthunt.com', "@#{ object.user.username }")
    end

    def segments
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.segments
    end

    def subscriber_searches
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.subscriber_searches
    end

    def maker_tasks
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.maker_tasks.pending
    end

    def subscriber_search(id:)
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.subscriber_searches.find_by id: id
    end

    def segment(id:)
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.segments.find_by id: id
    end

    def conversations
      return [] unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.conversations.not_trashed.by_date
    end

    def jobs_url
      return unless object.hiring?

      klass = Graph::Resolvers::UpcomingPages::LinkResolver.build('angellist')
      klass.new(field: nil, object: object, context: context).resolve
    end

    def can_request_stripe_discount
      Ships::StripeDiscountCode.eligible?(object.account)
    end
  end
end
