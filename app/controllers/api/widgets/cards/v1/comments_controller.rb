# frozen_string_literal: true

class API::Widgets::Cards::V1::CommentsController < API::Widgets::Cards::V1::BaseController
  respond_to :json

  def show
    comment = Comment.find(params[:id])

    render json: Rewired.json_dump(API::Widgets::Cards::V1::CommentSerializer.resource(comment))
  end
end
