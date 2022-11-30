# frozen_string_literal: true

class Graph::Resolvers::Jobs::JobResolver < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :slug, String, required: false
  argument :token, String, required: false
  argument :published, Boolean, required: false

  type Graph::Types::JobType, null: true

  def resolve(id: nil, slug: nil, token: nil, published: nil)
    scope = published ? Job.published : Job.not_trashed

    if token.present?
      scope.find_by(token: token)
    elsif id.present? || slug.present?
      scope.find_by(slug: id || slug)
    end
  end
end
