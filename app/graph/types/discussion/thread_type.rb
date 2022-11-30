# frozen_string_literal: true

module Graph::Types
  class Discussion::ThreadType < BaseNode
    implements Graph::Types::CommentableInterfaceType
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::VotableInterfaceType
    implements Graph::Types::SubscribableInterfaceType

    graphql_name 'DiscussionThread'

    class StatusEnum < Graph::Types::BaseEnum
      graphql_name 'DiscussionThreadStatusEnum'

      ::Discussion::Thread.statuses.each do |name, value|
        value name, value
      end
    end

    class BetaEnum < Graph::Types::BaseEnum
      graphql_name 'DiscussionThreadBetaEnum'

      value 'ios', 'ios'
      value 'android', 'android'
    end

    field :title, String, null: false
    field :url, String, null: false
    field :description, String, null: true
    field :description_text, String, null: true
    field :description_html, String, null: true
    field :featured_at, DateTimeType, null: true
    field :trending_at, DateTimeType, null: true
    field :hidden_at, DateTimeType, null: true
    field :slug, String, null: false
    field :created_at, DateTimeType, null: false
    field :can_discuss, resolver: Graph::Resolvers::Can.build(:create_discussion, &:subject)
    field :can_edit, resolver: Graph::Resolvers::Can.build(:update)
    field :pinned, Boolean, null: false
    field :status, StatusEnum, null: true
    field :beta, BetaEnum, null: true
    association :user, Graph::Types::UserType, null: false
    association :poll, Poll::PollType, null: true
    association :subject, Graph::Types::Discussion::ThreadSubjectType, null: false
    association :category, Graph::Types::Discussion::CategoryType, null: true

    def url
      Routes.discussion_url object
    end

    def description_html
      BetterFormatter.call(object.description, mode: :full)
    end

    def description_text
      ::Discussions.description_text object.description
    end

    def beta
      return unless object.subject_type == 'MakerGroup'

      case object.subject_id
      when MakerGroup::IOS_BETA
        'ios'
      when MakerGroup::ANDROID_BETA
        'android'
      end
    end
  end
end
