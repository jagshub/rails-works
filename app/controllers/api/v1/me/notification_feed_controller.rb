# frozen_string_literal: true

class API::V1::Me::NotificationFeedController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }
  DEFAULT_LIMIT = 20
  DEFAULT_OFFSET = 20

  def index
    render json: { notifications: [] }
  end

  def update
    render json: { notifications: [] }
  end
end
