# frozen_string_literal: true

class API::V1::AmaEventsController < API::V1::BaseController
  def index
    render json: []
  end

  def show
    render json: NOT_FOUND, status: :not_found

    handle_error_validation
  end

  NOT_FOUND = {
    error: 'not_found',
    error_description: 'We could not find any object with this ID',
  }.freeze
end
