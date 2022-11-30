# frozen_string_literal: true

class API::V1::AmaEvents::SubscriptionsController < API::V1::BaseController
  def create
    render json: NOT_FOUND, status: :not_found
  end

  def destroy
    head :no_content
  end

  NOT_FOUND = {
    error: 'not_found',
    error_description: 'We could not find any object with this ID',
  }.freeze
end
