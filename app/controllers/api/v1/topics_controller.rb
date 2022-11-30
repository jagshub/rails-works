# frozen_string_literal: true

class API::V1::TopicsController < API::V1::BaseController
  def index
    topics = API::V1::TopicsSearch.results filters: search_params, paging: filter_params

    return unless stale?(topics)

    render json: serialize_collection(API::V1::TopicSerializer, topics, root: :topics)
  end

  def show
    topic = Topic.find(params[:id])

    return unless stale?(topic)

    render json: serialize_resource(API::V1::TopicSerializer, topic, root: :topic)
  end
end
