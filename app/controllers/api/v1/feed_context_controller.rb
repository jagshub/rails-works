# frozen_string_literal: true

class API::V1::FeedContextController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }, only: [:index]

  def index
    # NOTE(Mike Coutermarsh): This is deprecated. Returning an empty array so we don't
    #   break the endpoint
    render json: { items: [] }.to_json
  end
end
