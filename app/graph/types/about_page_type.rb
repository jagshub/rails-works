# frozen_string_literal: true

module Graph::Types
  class AboutPageType < BaseObject
    field :members, [AboutPageMemberType], null: false
    field :thankful, [UserType], null: false
    field :angel_investors, [UserType], null: false
  end
end
