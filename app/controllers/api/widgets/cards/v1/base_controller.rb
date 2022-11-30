# frozen_string_literal: true

class API::Widgets::Cards::V1::BaseController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  private

  NOT_FOUND = {
    error: 'not_found',
    error_description: 'We could not find any object with this ID',
  }.freeze

  def handle_record_not_found
    render json: NOT_FOUND, status: :not_found
  end
end
