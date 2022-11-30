# frozen_string_literal: true

module API::V2Internal::Types
  class ProductLinkType < BaseObject
    graphql_name 'ProductLink'

    field :id, ID, null: false
    field :website_name, String, null: false
    field :devices, [String], null: false
    field :rating, Float, null: true
    field :price, Float, null: true
    field :platform, String, null: false
    field :redirect_path, String, null: false

    def platform
      object.store_name || ::PlatformStores::WEBSITE
    end

    def redirect_path
      Routes.short_link_url(object.short_code, app_id: context[:current_application])
    end
  end
end
