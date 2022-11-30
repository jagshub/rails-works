# frozen_string_literal: true

module Graph::Types
  class ClearbitPersonalProfileType < BaseObject
    graphql_name 'ClearbitPersonalProfile'

    field :gender, String, null: true
    field :bio, String, null: true
    field :site, String, null: true
    field :employment_name, String, null: true
    field :employment_title, String, null: true
    field :employment_domain, String, null: true
    field :geo_city, String, null: true
    field :geo_state, String, null: true
    field :geo_country, String, null: true
    field :github_handle, String, null: true
    field :twitter_handle, String, null: true
    field :linkedin_handle, String, null: true
    field :gravatar_handle, String, null: true
    field :aboutme_handle, String, null: true
  end
end
