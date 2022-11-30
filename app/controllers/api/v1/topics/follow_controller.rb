# frozen_string_literal: true

class API::V1::Topics::FollowController < API::V1::BaseController
  def create
    Subscribe.subscribe(find_topic, current_user) if current_user

    head :created
  end

  def destroy
    Subscribe.unsubscribe(find_topic, current_user) if current_user

    head :no_content
  end

  private

  def find_topic
    Topic.find(params[:topic_id])
  end
end
