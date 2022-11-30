# frozen_string_literal: true

class API::V1::Me::InteractionsController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }, only: [:index]

  def index
    interactions = API::V1::UserInteractions.new(current_user).interactions(params[:include])

    render json: interactions, status: :ok
  end
end
