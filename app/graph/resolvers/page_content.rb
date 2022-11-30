# frozen_string_literal: true

class Graph::Resolvers::PageContent < Graph::Resolvers::Base
  argument :page_key, String, required: true

  type [Graph::Types::PageContentType], null: false

  def resolve(page_key:)
    PageContent.where(page_key: page_key).order(:id)
  end
end
