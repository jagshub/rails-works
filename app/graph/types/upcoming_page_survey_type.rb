# frozen_string_literal: true

module Graph::Types
  class UpcomingPageSurveyType < BaseObject
    graphql_name 'UpcomingPageSurvey'

    extend Graph::Utils::AuthorizeRead

    implements Graph::Types::SeoInterfaceType

    field :id, ID, null: false
    field :title, String, null: false
    field :description, Graph::Types::HTMLType, null: true
    field :welcome_text, Graph::Types::HTMLType, null: true
    field :success_text, Graph::Types::HTMLType, null: true
    field :status, String, null: false
    field :updated_at, Graph::Types::DateTimeType, null: false
    field :button_color, String, null: true
    field :button_text_color, String, null: true
    field :link_color, String, null: true
    field :title_color, String, null: true
    field :background_color, String, null: true
    field :background_image_uuid, String, null: true
    field :closed_at, Graph::Types::DateTimeType, null: true
    field :created_at, Graph::Types::DateTimeType, null: true
    field :is_opened, Boolean, method: :opened?, null: false
    field :subscribers, Graph::Types::UpcomingPageSubscriberType.connection_type,  null: false, resolver: Graph::Resolvers::AuthorizationAssociation.build(:subscribers), connection: true
    field :respondent, resolver: Graph::Resolvers::UpcomingPages::Surveys::RespondentResolver
    field :respondent_count, resolver: Graph::Resolvers::UpcomingPages::Surveys::RespondentCountResolver
    field :questions, resolver: Graph::Resolvers::UpcomingPages::Surveys::QuestionsResolver
    field :can_manage, resolver: Graph::Resolvers::Can.build(ApplicationPolicy::MAINTAIN)
    field :results, resolver: Graph::Resolvers::UpcomingPages::Surveys::ResultsResolver

    association :upcoming_page, Graph::Types::UpcomingPageType, null: false

    def closed_at
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.closed_at
    end

    def created_at
      return unless ApplicationPolicy.can?(context[:current_user], ApplicationPolicy::MAINTAIN, object)

      object.created_at
    end
  end
end
