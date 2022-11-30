# frozen_string_literal: true

module Mobile::Graph::Types
  class Discussion::ThreadType < BaseNode
    implements Mobile::Graph::Types::CommentableInterfaceType
    implements Mobile::Graph::Types::VotableInterfaceType

    graphql_name 'DiscussionThread'

    class StatusEnum < Mobile::Graph::Types::BaseEnum
      graphql_name 'DiscussionThreadStatusEnum'

      ::Discussion::Thread.statuses.each do |name, value|
        value name, value
      end
    end

    field :can_discuss, resolver: Mobile::Graph::Utils::CanResolver.build(:create_discussion, &:subject)
    field :can_edit, resolver: Mobile::Graph::Utils::CanResolver.build(:update)
    field :created_at, DateTimeType, null: false
    field :description, String, null: true, deprecation_reason: 'Use formattedDescription'
    field :description_html, String, null: true, deprecation_reason: 'Use formattedDescription'
    field :description_md, String, null: true, deprecation_reason: 'Use formattedDescription'
    field :description_text, String, null: true, deprecation_reason: 'Use formattedDescription'
    field :formatted_description, FormattedTextType, null: true, method: :description
    field :featured_at, DateTimeType, null: true
    field :hidden_at, DateTimeType, null: true
    field :trashed_at, DateTimeType, null: true
    field :pinned, Boolean, null: false
    field :slug, String, null: false
    field :status, StatusEnum, null: true
    field :title, String, null: false
    field :trending_at, DateTimeType, null: true

    association :category, Mobile::Graph::Types::Discussion::CategoryType, null: true
    association :poll, Mobile::Graph::Types::PollType, null: true
    association :user, Mobile::Graph::Types::UserType, null: false

    def description_html
      BetterFormatter.call(object.description, mode: :full)
    end

    def description_md
      html = description_html

      return if html.blank?

      ::ReverseMarkdown.convert html
    end

    def description_text
      ::Discussions.description_text object.description
    end
  end
end
