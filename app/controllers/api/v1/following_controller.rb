# frozen_string_literal: true

class API::V1::FollowingController < API::V1::BaseController
  def index
    @associations = API::V1::FollowersSearch.results filters: search_params, paging: filter_params

    return unless stale?(@associations)

    render json: serialize_collection(API::V1::FollowingSerializer, @associations, root: :following)
  end

  private

  def search_params
    super.merge(follower_user_id: params[:user_id])
  end
end
