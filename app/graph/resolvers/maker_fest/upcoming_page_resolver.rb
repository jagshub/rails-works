# frozen_string_literal: true

class Graph::Resolvers::MakerFest::UpcomingPageResolver < Graph::Resolvers::Base
  class MakerFestParticipant < Graph::Types::BaseObject
    graphql_name 'MakerFestParticipant'

    field :id, ID, null: false
    field :upcoming_page, Graph::Types::UpcomingPageType, null: false
    field :external_link, String, null: true
    field :has_voted, Boolean, null: false
  end

  class MakerFestCategoryType < Graph::Types::BaseObject
    graphql_name 'MakerFestCategory'

    field :name, String, null: false
    field :category_slug, String, null: false
    field :emoji, String, null: false
    field :description, String, null: false
    field :participants, [MakerFestParticipant], null: false
  end

  class MakerFestWrapperType < Graph::Types::BaseObject
    graphql_name 'MakerFestWrapper'

    field :categories, [MakerFestCategoryType], null: false
    field :is_logged_in, Boolean, null: false
    field :voting_ended, Boolean, null: false
  end

  type MakerFestWrapperType, null: true

  SLUGS = ['social', 'voice', 'health', 'inclusion', 'brain', 'remote', 'other'].freeze

  def resolve
    voting_ended = ::MakerFest::Submission.voting_ended?

    voted_ids = !voting_ended && current_user.present? ? current_user.votes.where(subject_type: ::MakerFest::Participant.name).pluck(:subject_id) : []

    participants = ::MakerFest::Participant.all.group_by(&:category_slug)

    categories = SLUGS.map do |category_slug|
      ::MakerFest::Category.new category_slug, participants[category_slug], voted_ids if participants[category_slug].present?
    end

    OpenStruct.new(
      categories: categories.compact,
      is_logged_in: current_user.present?,
      voting_ended: voting_ended,
    )
  end
end
