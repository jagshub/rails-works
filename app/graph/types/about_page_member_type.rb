# frozen_string_literal: true

module Graph::Types
  class AboutPageMemberType < BaseObject
    field :title, String, null: false
    field :user, UserType, null: false
    field :country_code, String, null: true
  end
end
