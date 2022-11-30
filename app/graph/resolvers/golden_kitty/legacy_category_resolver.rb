# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::LegacyCategoryResolver < Graph::Resolvers::Base
  type Graph::Types::GoldenKittyCategoryLegacyType, null: false

  argument :year, String, required: true

  def resolve(year:)
    categories = GoldenKitty::Category.where(year: year).by_priority

    OpenStruct.new(
      categories: categories,
      next_categories: categories.select { |category| category.voting_enabled_at&.to_date == Time.current.to_date + 1 },
      nominationEnded: ::GoldenKitty::Utils.nomination_ended?,
      votingEnded: ::GoldenKitty::Utils.voting_ended?,
      maker: ::GoldenKitty::MakerCommunityCategory.call('maker'),
      community: ::GoldenKitty::MakerCommunityCategory.call('community'),
    )
  end
end
