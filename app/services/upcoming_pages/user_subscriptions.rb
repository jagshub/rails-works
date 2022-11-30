# frozen_string_literal: true

module UpcomingPages::UserSubscriptions
  extend self

  def call(user)
    return [] if user.blank?

    UpcomingPageSubscriber.joins(:contact).where('ship_contacts.user_id' => user.id).pluck(:upcoming_page_id)
  end
end
