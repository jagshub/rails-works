# frozen_string_literal: true

class Admin::CreateMarketingNotificationsForm < Admin::BaseForm
  attributes :user_ids, :heading, :body, :one_liner, :deeplink
  attr_reader :current_user

  validates :heading, presence: true
  validates :current_user, presence: true

  def initialize(current_user:)
    @current_user = current_user
  end

  def perform
    deeplink = 'producthunt://home' if deeplink.blank?

    ids = user_ids

    ids = ids.split(',').reject(&:blank?).map(&:to_i)

    users = User.where id: ids

    valid_user_ids = users.reject(&:blank?).map(&:id).join(',')

    object = MarketingNotification.create!(
      user_ids: valid_user_ids,
      heading: heading,
      body: body,
      one_liner: one_liner,
      deeplink: deeplink,
      sender_id: current_user.id,
    )

    Notifications.notify_about(kind: 'community_updates', object: object)
  end
end
