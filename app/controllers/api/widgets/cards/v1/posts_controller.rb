# frozen_string_literal: true

class API::Widgets::Cards::V1::PostsController < API::Widgets::Cards::V1::BaseController
  respond_to :json

  def show
    post = Post.visible.friendly.find(params[:id])

    render json: Rewired.json_dump(API::Widgets::Cards::V1::PostSerializer.resource(post))
  end
end
