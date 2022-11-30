# frozen_string_literal: true

class API::V1::Collections::SubscriptionsController < API::V1::BaseController
  def create
    CollectionSubscription.subscribe(collection, user: current_user, email: params[:email])

    head :created
  rescue ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  def destroy
    CollectionSubscription.unsubscribe(collection, user: current_user, email: params[:email])

    head :no_content
  end

  private

  def collection
    @collection ||= Collection.find(params[:collection_id])
  end
end
