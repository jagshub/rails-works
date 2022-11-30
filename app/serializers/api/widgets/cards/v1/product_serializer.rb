# frozen_string_literal: true

class API::Widgets::Cards::V1::ProductSerializer < BaseSerializer
  delegated_attributes(
    :id,
    :name,
    :tagline,
    :media,
    :followers_count,
    :created_at,
    to: :resource,
  )

  def media
    API::Widgets::Cards::V1::MediaSerializer.cache_collection(resource.media)
  end

  attributes :follower_ids, :url

  def follower_ids
    resource
      .followers
      .order(follower_count: :desc)
      .limit(3)
      .pluck(:id)
  end

  def url
    api_widgets_cards_redirect_url(::Cards.id_for(resource))
  end
end
