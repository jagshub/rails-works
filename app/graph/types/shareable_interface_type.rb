# frozen_string_literal: true

module Graph::Types
  module ShareableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Shareable'

    field :id, ID, null: false
    field :url, String, null: false

    def url
      Routes.subject_url(object)
    end
  end
end
