# frozen_string_literal: true

class Products::UpdateForm
  include MiniForm::Model

  model :product, save: true, attributes: %i(
    name
    tagline
    logo_uuid
    description
    twitter_url
  )

  attributes :media, :product, :user

  alias graphql_result product

  def initialize(product, user:)
    @product = product
    @user = user
  end

  def update(**params)
    Audited.audit_class.as_user(user) do
      super(**params)
    end
  end

  def perform
    Products::Update::Media.call(product: product, user: user, media: media)
  end
end
