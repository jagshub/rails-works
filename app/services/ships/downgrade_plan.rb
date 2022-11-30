# frozen_string_literal: true

class Ships::DowngradePlan
  attr_reader :subscription

  class << self
    def call(subscription)
      new(subscription).call
    end
  end

  def initialize(subscription)
    @subscription = subscription
  end

  def call
    return handle_free_subscription if subscription.free?
    return handle_pro_subscription if subscription.pro?

    false
  end

  private

  def handle_pro_subscription
    upcoming_pages.each do |upcoming_page|
      upcoming_page.update!(webhook_url: nil)
    end
  end

  def handle_free_subscription
    user.update!(role: user.ship_user_metadata.initial_role) if user.ship_user_metadata.present? && user.ship_user_metadata.initial_role != user.role

    upcoming_pages.each do |upcoming_page|
      UpcomingPage.transaction do
        upcoming_page.update!(
          webhook_url: nil,
          featured_at: nil,
          status: :unlisted,
        )

        upcoming_page.segments.each(&:trash)
        upcoming_page.variants.b.destroy_all
        upcoming_page.messages.continuous.update_all(kind: :one_off)

        # NOTE(vesln): When user has created multiple upcoming page, we still keep those
      end
    end
  end

  def user
    subscription.user
  end

  def upcoming_pages
    user.upcoming_pages
  end
end
