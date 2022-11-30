# frozen_string_literal: true

class API::V1::CommentsController < API::V1::BaseController
  def index
    @comments = API::V1::CommentsSearch.results filters: search_params, paging: filter_params

    return unless stale?(@comments)

    render json: serialize_collection(API::V1::CommentSerializer, @comments)
  end

  def create
    form = ::Comments::CreateForm.new(
      user: current_user,
      source: :api,
      request_info: request_info.merge(oauth_application_id: current_application.id),
    )

    if form.update comment_params.merge(subject: find_subject)
      render json: serialize_resource(API::V1::CommentSerializer, form.comment),
             status: :created
    else
      handle_error_validation form.comment
    end
  end

  def update
    form = ::Comments::UpdateForm.new(comment: find_comment, user: current_user, request_info: request_info)

    if form.update comment_params
      render json: serialize_resource(API::V1::CommentSerializer, form.comment),
             status: :ok
    else
      handle_error_validation form.comment
    end
  end

  private

  def serialization_scope
    exclude = Array(params[:exclude])
    exclude << :post if search_params['post_id'].present?
    exclude << :user if search_params['user_id'].present?

    super.merge(exclude: exclude)
  end

  # Note(andreasklinger): Added to allow /v1/users/:user_id/comments routes
  def search_params
    super.merge(params.permit(:user_id))
  end

  def comment_params
    params
      .require(:comment)
      .permit(
        :body,
        :parent_comment_id,
      )
  end

  def find_comment
    Comment.find(params[:id])
  end

  def find_subject
    Post.find(params[:comment][:post_id])
  end
end
