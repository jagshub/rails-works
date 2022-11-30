# frozen_string_literal: true

class API::Widgets::Cards::V1::ReviewsController < API::Widgets::Cards::V1::BaseController
  respond_to :json

  def show
    review = Review.find(params[:id])

    render json: Rewired.json_dump(API::Widgets::Cards::V1::ReviewSerializer.resource(review))
  end
end
