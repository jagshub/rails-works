# frozen_string_literal: true

# NOTE(rstankov): This only applies during the Maker Festival
#   We give one extra upcoming page for participants.
module Ships::MakerFestival
  extend self

  SEGMENT_ID = 900

  DATE = Date.new(2018, 11, 20)

  def segment_id
    SEGMENT_ID
  end

  def participant?(user)
    UpcomingPageSegmentSubscriberAssociation.where(
      upcoming_page_subscriber_id: user.upcoming_page_subscriptions.select(:id),
      upcoming_page_segment_id: segment_id,
    ).exists?
  end

  # NOTE(rstankov): THIS CAN BE REMOVED on 05-12-2018
  def allowed_extra_page?(user)
    return false unless participant?(user)
    return false if user.ship_account.upcoming_pages.visible.where('created_at > ?', DATE).exists?

    true
  end
end
