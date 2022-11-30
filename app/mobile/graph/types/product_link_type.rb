# frozen_string_literal: true

module Mobile::Graph::Types
  class ProductLinkType < BaseObject
    graphql_name 'ProductLink'

    field :id, ID, null: false
    field :url, String, null: false
    field :website_name, String, null: false
    field :platform, String, null: false
    field :redirect_path, String, null: false
    field :primary_link, Boolean, null: false

    def website_name
      URI.parse(object.url).host
    rescue URI::InvalidURIError
      ''
    end

    def platform
      object.store_name || PlatformStores::WEBSITE
    end

    def redirect_path
      Routes.short_link_path(object.short_code)
    end
  end
end
