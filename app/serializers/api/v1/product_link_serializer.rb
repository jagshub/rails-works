# frozen_string_literal: true

class API::V1::ProductLinkSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :post_id,
    :created_at,
    :primary_link,
    :rating,
    :website_name,
    to: :resource,
  )

  attributes(
    :redirect_url,
    :primary_link,
    :platform,
  )

  delegate :post, to: :resource

  def platform
    resource.store
  end

  def redirect_url
    short_link_url(resource.short_code, post.id, app_id: scope[:current_application].try(:id))
  end
end
