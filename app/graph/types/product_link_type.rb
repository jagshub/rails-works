# frozen_string_literal: true

module Graph::Types
  class ProductLinkType < BaseObject
    graphql_name 'ProductLink'

    field :id, ID, null: false
    field :url, String, null: false
    field :devices, [String], null: false
    field :rating, Float, null: true
    field :price, Float, null: true
    field :website_name, String, null: false
    field :store_name, String, null: false
    field :redirect_path, String, null: false

    def website_name
      URI.parse(object.url).host
    rescue URI::InvalidURIError
      ''
    end

    def store_name
      object.store_name || PlatformStores::WEBSITE
    end

    def redirect_path
      Routes.short_link_path(object.short_code)
    end
  end
end
