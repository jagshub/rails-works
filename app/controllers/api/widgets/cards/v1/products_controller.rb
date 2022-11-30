# frozen_string_literal: true

class API::Widgets::Cards::V1::ProductsController < API::Widgets::Cards::V1::BaseController
  respond_to :json

  def show
    product = Product.visible.friendly.find(params[:id])

    render json: Rewired.json_dump(
      API::Widgets::Cards::V1::ProductSerializer.resource(product),
    )
  end
end
