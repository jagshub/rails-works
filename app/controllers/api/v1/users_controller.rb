# frozen_string_literal: true

class API::V1::UsersController < API::V1::BaseController
  def index
    @users = API::V1::UsersSearch.results filters: search_params, paging: filter_params

    return unless stale?(@users)

    render json: serialize_collection(API::V1::BasicUserSerializer, @users)
  end

  def show
    @user = find_user

    return unless stale?(@user)

    render json: serialize_resource(API::V1::UserSerializer, @user)
  end

  private

  def find_user
    if /^\d+$/.match? params[:id]
      User.find(params[:id])
    else
      User.find_by_username!(params[:id])
    end
  end
end
