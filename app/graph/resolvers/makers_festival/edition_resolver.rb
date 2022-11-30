# frozen_string_literal: true

class Graph::Resolvers::MakersFestival::EditionResolver < Graph::Resolvers::Base
  type Graph::Types::MakersFestival::EditionType, null: true

  argument :slug, String, required: true

  def resolve(slug:)
    return if slug.blank?

    ::MakersFestival::Edition.friendly.find(slug)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
