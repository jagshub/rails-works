# frozen_string_literal: true

class API::V1::Collections::PostAssociationsController < API::V1::BaseController
  before_action :load_collection, only: %i(create destroy)

  def create
    authorize! :update, @collection

    @collected_post = CollectionPosts.add(@collection, params[:post_id])

    if @collected_post.errors.empty?
      render json: serialize_resource(API::V1::Collections::CollectedPostSerializer, @collected_post, root: :collected_post), status: :created
    else
      handle_error_validation @collected_post
    end
  end

  def destroy
    authorize! :update, @collection

    @collected_post = @collection.collection_post_associations.find_by(post_id: params[:post_id])
    CollectionPosts.remove(@collected_post)

    if @collected_post
      render json: serialize_resource(API::V1::Collections::CollectedPostSerializer, @collected_post, root: :collected_post),
             status: :ok
    else
      handle_record_not_found
    end
  end

  private

  def load_collection
    @collection = current_user.collections.with_preloads.find(params[:collection_id])
  end
end
