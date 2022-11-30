# frozen_string_literal: true

module Graph::Types
  class UpcomingPageMakerTaskType < BaseObject
    graphql_name 'UpcomingPageMakerTask'

    extend Graph::Utils::AuthorizeRead

    field :id, ID, null: false
    field :kind, String, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :url, String, null: false
  end
end
