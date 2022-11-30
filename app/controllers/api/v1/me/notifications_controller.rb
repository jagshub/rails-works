# frozen_string_literal: true

class API::V1::Me::NotificationsController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }, only: [:index]

  def index
    # NOTE(rstankov): This was using the legacy notification notification counts
    #   The new activity doesn't provide total/unseen out of the box
    #   So, keep it active, but just return 0
    notifications = {
      total: 0,
      unseen: 0,
    }

    render json: { notifications: notifications }, status: :ok
  end
end
