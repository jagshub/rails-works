# frozen_string_literal: true

class API::V1::NotificationsController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :private }, only: [:show]

  def show
    notifications = fetch_notifications

    return unless stale? notifications

    render_notifications notifications
  end

  def destroy
    # Note(rstankov): Keep for backward compatability
    render_notifications []
  end

  private

  def render_notifications(notifications)
    render json: serialize_collection(API::V1::NotificationSerializer, notifications, root: :notifications)
  end

  def fetch_notifications
    # Note(rstankov): New notifications don't have ids, so `newer` and `older` won't work
    return [] if params[:newer].present? || params[:older].present?

    API::V1::Feed.feed_for(current_user)
  end
end
