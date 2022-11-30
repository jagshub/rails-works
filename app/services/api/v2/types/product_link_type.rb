# frozen_string_literal: true

module API::V2::Types
  class ProductLinkType < BaseObject
    description 'Product link from a post.'

    field :url, String, null: false
    field :type, String, null: false

    def url
      Routes.short_link_url(object.short_code, context.url_tracking_params)
    end

    def type
      object.store_name || PlatformStores::WEBSITE
    end
  end
end
