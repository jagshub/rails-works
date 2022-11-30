# frozen_string_literal: true

class API::Widgets::Upcoming::V1::UpcomingController < ApplicationController
  before_action :remove_x_frame
  skip_before_action :verify_origin

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    upcoming_page = UpcomingPage.find(params[:id])

    render json: Rewired.json_dump(API::Widgets::Upcoming::V1::UpcomingSerializer.resource(upcoming_page))
  end

  private

  NOT_FOUND = {
    error: 'not_found',
    error_description: 'We could not find any object with this ID',
  }.freeze

  def handle_record_not_found
    render json: NOT_FOUND, status: :not_found
  end

  def remove_x_frame
    response.headers.except! 'X-Frame-Options'
  end
end
