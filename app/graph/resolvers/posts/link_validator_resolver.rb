# frozen_string_literal: true

class Graph::Resolvers::Posts::LinkValidatorResolver < Graph::Resolvers::Base
  class PostLinkValidationStatus < Graph::Types::BaseEnum
    value 'VALID'
    value 'INVALID'
    value 'ERROR'
    value 'DUPLICATE'
    value 'PRODUCT_EXISTS'
    value 'ENTERED_PH_URL'
  end

  class PostLinkValidatonType < Graph::Types::BaseObject
    field :status, PostLinkValidationStatus, null: false
    field :post, Graph::Types::PostType, null: true
    field :product, Graph::Types::ProductType, null: true
  end

  type PostLinkValidatonType, null: true

  argument :url, String, required: false
  argument :product_id, String, required: false

  def resolve(url: nil, product_id: nil)
    if UrlParser.ph_url?(url) && !current_user.admin?
      return {
        status: 'ENTERED_PH_URL',
        post: nil,
        product: nil,
      }
    end

    status, post = ::Posts::LinkValidator.call(url)

    search_for_product = status == :valid && product_id.blank?
    product = search_for_product ? Products::Find.by_url(url) : nil

    status = if product.present?
               'PRODUCT_EXISTS'
             else
               status.to_s.upcase
             end
    {
      status: status,
      post: post,
      product: product,
    }
  end
end
