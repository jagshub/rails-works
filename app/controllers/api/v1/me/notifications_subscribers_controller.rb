# frozen_string_literal: true

class API::V1::Me::NotificationsSubscribersController < API::V1::BaseController
  def create
    subscriber = Subscribers.register(device_params.merge(user: current_user))

    if subscriber.valid?
      render json: {}, status: :created
    else
      handle_error_validation subscriber
    end
  rescue ActiveRecord::RecordInvalid
    render json: {}, status: :unprocessable_entity
  end

  private

  def device_params
    params.require(:notification_subscriber).permit(Subscriber::TOKENS).to_h
  end

  # Note(andreasklinger): Guests can subscribe to notifications
  def public_endpoint?
    true
  end
end
