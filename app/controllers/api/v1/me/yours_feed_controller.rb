# frozen_string_literal: true

class API::V1::Me::YoursFeedController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }, only: [:index]

  def index
    posts = []
    render json: serialize_collection(API::V1::BasicPostSerializer, posts, root: :posts)
  end

  private

  def page_param
    params[:page]
  end

  def per_page
    params[:per_page] || 20
  end
end
