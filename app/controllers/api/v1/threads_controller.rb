# frozen_string_literal: true

class API::V1::ThreadsController < API::V1::BaseController
  def index
    @comments = API::V1::CommentsSearch.results filters: search_params, paging: filter_params

    return unless stale?(@comments)

    render json: serialize_collection(API::V1::ThreadSerializer, @comments)
  end

  private

  def search_params
    # NOTE(andreasklinger): Merging subject_ids (from routes) to allow nested routes.
    super.merge(top_level_only: true).merge(params.permit(:post_id))
  end

  def serialization_scope
    exclude = Array(params[:exclude])
    exclude << :post
    super.merge(exclude: exclude)
  end

  def default_filter_values
    { order: :asc }
  end
end
