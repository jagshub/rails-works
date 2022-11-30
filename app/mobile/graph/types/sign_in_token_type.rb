# frozen_string_literal: true

module Mobile::Graph::Types
  class SignInTokenType < BaseObject
    field :access_token, String, null: false
    field :type, String, null: false
    field :first_time_user, Boolean, null: true
  end
end
