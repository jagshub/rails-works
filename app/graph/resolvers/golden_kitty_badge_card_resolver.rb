# frozen_string_literal: true

class Graph::Resolvers::GoldenKittyBadgeCardResolver < Graph::Resolvers::Base
  type String, null: true

  def resolve
    Loader.for.load(object)
  end

  class Loader < GraphQL::Batch::Loader
    def perform(badges)
      editions = GoldenKitty::Edition
                 .where(year: badges.map(&:year))
                 .group_by(&:year)

      badges.each do |badge|
        fulfill(
          badge,
          editions.dig(badge.year.to_i, 0)&.card_image_uuid,
        )
      end
    end
  end
end
