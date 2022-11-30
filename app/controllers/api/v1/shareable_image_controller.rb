# frozen_string_literal: true

class API::V1::ShareableImageController < API::V1::BaseController
  def show
    comment = Comment.find(params[:comment_id])
    redirect_to Sharing.image_for(comment)
  end
end
