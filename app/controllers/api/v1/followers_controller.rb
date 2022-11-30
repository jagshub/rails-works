# frozen_string_literal: true

class API::V1::FollowersController < API::V1::BaseController
  before_action :load_friend, only: %i(create destroy)

  def index
    @associations = API::V1::FollowersSearch.results filters: search_params, paging: filter_params

    return unless stale?(@associations)

    render json: serialize_collection(API::V1::FollowerSerializer, @associations, root: :followers)
  end

  def create
    authorize! :create, UserFriendAssociation

    @association = Following.follow(
      user: current_user,
      follows: @friend,
      source: :api,
      request_info: request_info.merge(oauth_application_id: current_application.id),
    )

    if @association.valid?
      render json: serialize_resource(API::V1::FollowerSerializer, @association, root: :follower),
             status: :created
    else
      handle_error_validation @association
    end
  end

  def destroy
    authorize! :destroy, UserFriendAssociation

    if current_user.follows? @friend
      @association = Following.unfollow(user: current_user, unfollows: @friend)

      render json: serialize_resource(API::V1::FollowerSerializer, @association, root: :follower),
             status: :ok
    else
      handle_record_not_found
    end
  end

  private

  def load_friend
    @friend = User.with_preloads.find(params[:user_id])
  end

  def search_params
    super.merge(following_user_id: params[:user_id])
  end
end
