# frozen_string_literal: true

class API::Widgets::Cards::V1::PostSerializer < BaseSerializer
  self.root = true

  delegated_attributes(
    :id,
    :name,
    :tagline,
    :media,
    :votes_count,
    to: :resource,
  )

  attributes(
    :upvoter_ids,
    :url,
  )

  def media
    API::Widgets::Cards::V1::MediaSerializer.cache_collection(resource.media)
  end

  def upvoter_ids
    resource
      .voters
      .order(follower_count: :desc)
      .limit(20)
      .sample(3)
      .map(&:id)
  end

  def url
    api_widgets_cards_redirect_url(::Cards.id_for(resource))
  end
end
