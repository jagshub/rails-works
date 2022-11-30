# frozen_string_literal: true

class API::V1::TopicsSearch
  include SearchObject.module
  include API::V1::Sorting

  scope { Topic.all }

  option(:slug)
  option(:follower_id) { |scope, value| scope.joins(:subscriptions).where('subscriptions.subscriber_id' => Subscriber.find_by(user_id: value)) }

  sort_by :id, :created_at, :updated_at
end
