# frozen_string_literal: true

class API::Widgets::Cards::V1::ReviewSerializer < BaseSerializer
  self.root = true

  delegated_attributes(
    :id,
    :rating,
    :created_at,
    to: :resource,
  )

  attributes(
    :body_html,
    :product,
    :url,
    :user,
  )

  def body_html
    BetterFormatter.call(resource.body, mode: :full)
  end

  def user
    API::Widgets::Cards::V1::UserSerializer.resource(resource.user)
  end

  def product
    API::Widgets::Cards::V1::ProductSerializer.resource(resource.product, nil, root: false)
  end

  def url
    api_widgets_cards_redirect_url(::Cards.id_for(resource))
  end
end
