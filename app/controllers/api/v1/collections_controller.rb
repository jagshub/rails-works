# frozen_string_literal: true

class API::V1::CollectionsController < API::V1::BaseController
  before_action :load_collection, only: %i(update destroy)

  def index
    @collections = API::V1::CollectionsSearch.results filters: search_params, paging: filter_params

    return unless stale?(@collections)

    render json: serialize_collection(API::V1::BasicCollectionSerializer, @collections, root: :collections)
  end

  def show
    @collection = Collection.with_preloads.includes(posts: %i(makers user)).find(params[:id])

    return unless stale?(@collection)

    render json: serialize_resource(API::V1::CollectionSerializer, @collection)
  end

  def create
    @collection = current_user.collections.new(collection_params)

    if @collection.save
      render json: serialize_resource(API::V1::CollectionSerializer, @collection),
             status: :created
    else
      handle_error_validation @collection
    end
  end

  def update
    authorize! :update, @collection

    if @collection.update(collection_params)
      render json: serialize_resource(API::V1::CollectionSerializer, @collection),
             status: :ok
    else
      handle_error_validation @collection
    end
  end

  def destroy
    authorize! :destroy, @collection

    @collection.destroy
    render json: serialize_resource(API::V1::BasicCollectionSerializer, @collection),
           status: :ok
  end

  private

  def load_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :title)
  end

  def search_params
    super.merge(params.permit(:user_id, :post_id).to_h)
  end
end
